import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_data.dart';
import '../domain/ledger.dart';
import '../domain/models.dart';

/// "Now" for the prototype. Overridden in tests for deterministic data.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final accountsProvider = Provider<List<Account>>((ref) => mockAccounts);

final accountByIdProvider = Provider<Map<String, Account>>((ref) {
  return {for (final a in ref.watch(accountsProvider)) a.id: a};
});

/// In-memory store, newest first. Replaced by a repository in a later phase.
class TransactionsNotifier extends StateNotifier<List<MoneyTransaction>> {
  TransactionsNotifier(List<MoneyTransaction> initial)
    : super(_sorted(initial));

  static List<MoneyTransaction> _sorted(Iterable<MoneyTransaction> items) =>
      items.toList()..sort(compareNewestFirst);

  void add(MoneyTransaction transaction) {
    state = _sorted([...state, transaction]);
  }

  void update(MoneyTransaction transaction) {
    state = _sorted([
      for (final t in state) t.id == transaction.id ? transaction : t,
    ]);
  }

  void delete(String id) {
    state = state.where((t) => t.id != id).toList();
  }
}

final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, List<MoneyTransaction>>((ref) {
      final now = ref.watch(clockProvider)();
      return TransactionsNotifier(buildMockTransactions(now));
    });

/// Transactions grouped by local calendar day, each list newest first.
final transactionsByDayProvider =
    Provider<Map<DateTime, List<MoneyTransaction>>>((ref) {
      final byDay = <DateTime, List<MoneyTransaction>>{};
      for (final t in ref.watch(transactionsProvider)) {
        byDay.putIfAbsent(dateOnly(t.occurredAt), () => []).add(t);
      }
      return byDay;
    });

/// Account chip selected on Home (`null` = all accounts).
final homeAccountFilterProvider = StateProvider<String?>((ref) => null);

enum HomeViewMode { day, month }

final homeViewModeProvider = StateProvider<HomeViewMode>(
  (ref) => HomeViewMode.month,
);

/// [transactionsByDayProvider] narrowed to the Home account filter.
final homeTransactionsByDayProvider =
    Provider<Map<DateTime, List<MoneyTransaction>>>((ref) {
      final accountId = ref.watch(homeAccountFilterProvider);
      final byDay = ref.watch(transactionsByDayProvider);
      if (accountId == null) return byDay;
      return {
        for (final e in byDay.entries)
          if (e.value.any((t) => involvesAccount(t, accountId)))
            e.key: e.value.where((t) => involvesAccount(t, accountId)).toList(),
      };
    });

final dayTransactionsProvider =
    Provider.family<List<MoneyTransaction>, DateTime>((ref, day) {
      return ref.watch(transactionsByDayProvider)[dateOnly(day)] ?? const [];
    });

/// First day of the month shown on Home.
final selectedMonthProvider = StateProvider<DateTime>((ref) {
  return monthStart(ref.watch(clockProvider)());
});

final selectedDateProvider = StateProvider<DateTime>((ref) {
  return dateOnly(ref.watch(clockProvider)());
});

final monthTotalsProvider = Provider<PeriodTotals>((ref) {
  final month = ref.watch(selectedMonthProvider);
  final transactions = ref.watch(transactionsProvider);
  return totalsOf(transactions.where((t) => isSameMonth(t.occurredAt, month)));
});

final accountBalancesProvider = Provider<Map<String, int>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  return {
    for (final a in ref.watch(accountsProvider))
      a.id: accountBalance(a, transactions),
  };
});

final totalBalanceProvider = Provider<int>((ref) {
  return ref.watch(accountBalancesProvider).values.fold(0, (a, b) => a + b);
});

enum TransactionFilter { all, expense, income, transfer }

extension TransactionFilterMatch on TransactionFilter {
  bool matches(MoneyTransaction t) => switch (this) {
    TransactionFilter.all => true,
    TransactionFilter.expense => t.type == TransactionType.expense,
    TransactionFilter.income => t.type == TransactionType.income,
    TransactionFilter.transfer => t.type == TransactionType.transfer,
  };
}

/// Filter on the Transactions tab.
final transactionsFilterProvider = StateProvider<TransactionFilter>(
  (ref) => TransactionFilter.all,
);
