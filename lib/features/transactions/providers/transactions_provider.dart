import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/in_memory_ledger_repository.dart';
import '../domain/ledger.dart';
import '../domain/ledger_repository.dart';
import '../domain/ledger_rules.dart';
import '../domain/models.dart';
import '../domain/transaction_query.dart';

/// "Now". Overridden in tests for deterministic data.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Where data lives. Defaults to sample data in memory (demo mode and tests);
/// `main.dart` overrides it with Supabase when a backend is configured.
final ledgerRepositoryProvider = Provider<LedgerRepository>((ref) {
  return InMemoryLedgerRepository.demo(ref.watch(clockProvider)());
});

enum LedgerStatus { loading, ready, error }

class LedgerState {
  final LedgerStatus status;
  final List<Account> accounts;

  /// The user's own categories, including archived ones.
  final List<Category> customCategories;

  /// Newest first.
  final List<MoneyTransaction> transactions;

  const LedgerState({
    required this.status,
    this.accounts = const [],
    this.customCategories = const [],
    this.transactions = const [],
  });

  LedgerState copyWith({
    LedgerStatus? status,
    List<Account>? accounts,
    List<Category>? customCategories,
    List<MoneyTransaction>? transactions,
  }) => LedgerState(
    status: status ?? this.status,
    accounts: accounts ?? this.accounts,
    customCategories: customCategories ?? this.customCategories,
    transactions: transactions ?? this.transactions,
  );
}

/// Loads the signed-in user's accounts and transactions and applies changes.
/// Every change is saved in the repository before the state is updated, so
/// the UI never shows something that was not persisted.
class LedgerNotifier extends StateNotifier<LedgerState> {
  final LedgerRepository _repository;

  LedgerNotifier(this._repository)
    : super(const LedgerState(status: LedgerStatus.loading)) {
    load();
  }

  static List<MoneyTransaction> _sorted(Iterable<MoneyTransaction> items) =>
      items.toList()..sort(compareNewestFirst);

  Future<void> load() async {
    state = state.copyWith(status: LedgerStatus.loading);
    try {
      final accounts = await _repository.fetchAccounts();
      final categories = await _repository.fetchCustomCategories();
      final transactions = await _repository.fetchTransactions(categories);
      if (!mounted) return;
      state = LedgerState(
        status: LedgerStatus.ready,
        accounts: accounts,
        customCategories: categories,
        transactions: _sorted(transactions),
      );
    } on LedgerException {
      if (!mounted) return;
      state = state.copyWith(status: LedgerStatus.error);
    }
  }

  // Accounts --------------------------------------------------------------

  Future<Account> createAccount(Account account) async {
    final saved = await _repository.createAccount(account);
    if (mounted) state = state.copyWith(accounts: [...state.accounts, saved]);
    return saved;
  }

  /// The opening balance can't change once transactions use the account.
  Future<void> updateAccount(Account account) async {
    final current = state.accounts.firstWhere((a) => a.id == account.id);
    if (current.openingBalanceMinor != account.openingBalanceMinor &&
        accountInUse(account.id, state.transactions)) {
      throw const LedgerException.inUse();
    }
    final saved = await _repository.updateAccount(account);
    if (!mounted) return;
    state = state.copyWith(
      accounts: [for (final a in state.accounts) a.id == saved.id ? saved : a],
    );
  }

  /// Refused with [LedgerFailure.inUse] while transactions use it.
  Future<void> deleteAccount(Account account) async {
    if (accountInUse(account.id, state.transactions)) {
      throw const LedgerException.inUse();
    }
    await _repository.deleteAccount(account);
    if (!mounted) return;
    state = state.copyWith(
      accounts: state.accounts.where((a) => a.id != account.id).toList(),
    );
  }

  // Custom categories ------------------------------------------------------

  /// Creates, renames, recolors, archives or restores a custom category.
  Future<void> saveCategory(Category category) async {
    final isNew = !state.customCategories.any((c) => c.id == category.id);
    if (validateCategoryName(
          category.name ?? '',
          type: category.type,
          existing: state.customCategories,
          editingId: isNew ? null : category.id,
        ) ==
        NameError.duplicate) {
      throw const LedgerException.duplicate();
    }
    final saved = await _repository.saveCategory(category, isNew: isNew);
    if (!mounted) return;
    state = state.copyWith(
      customCategories: [
        for (final c in state.customCategories)
          if (c.id != saved.id) c,
        saved,
      ],
      // Existing transactions show the new name, icon and color.
      transactions: [
        for (final t in state.transactions)
          t.category?.id == saved.id ? t.withCategory(saved) : t,
      ],
    );
  }

  /// Refused with [LedgerFailure.inUse] while transactions use it; archive
  /// it instead.
  Future<void> deleteCategory(Category category) async {
    if (categoryInUse(category.id, state.transactions)) {
      throw const LedgerException.inUse();
    }
    await _repository.deleteCategory(category);
    if (!mounted) return;
    state = state.copyWith(
      customCategories: state.customCategories
          .where((c) => c.id != category.id)
          .toList(),
    );
  }

  // Transactions -------------------------------------------------------------

  /// Creates or updates [transaction]. Throws [LedgerException] on failure,
  /// leaving the state unchanged.
  Future<void> save(MoneyTransaction transaction) async {
    MoneyTransaction? previous;
    for (final t in state.transactions) {
      if (t.id == transaction.id) previous = t;
    }
    final saved = await _repository.saveTransaction(
      transaction,
      previous: previous,
    );
    if (!mounted) return;
    state = state.copyWith(
      transactions: _sorted([
        for (final t in state.transactions)
          if (t.id != saved.id) t,
        saved,
      ]),
    );
  }

  /// Throws [LedgerException] on failure, leaving the state unchanged.
  Future<void> delete(MoneyTransaction transaction) async {
    await _repository.deleteTransaction(transaction);
    if (!mounted) return;
    state = state.copyWith(
      transactions: state.transactions
          .where((t) => t.id != transaction.id)
          .toList(),
    );
  }
}

/// Rebuilt when the signed-in user changes, so one user's data never shows
/// for another.
final ledgerProvider = StateNotifierProvider<LedgerNotifier, LedgerState>((
  ref,
) {
  ref.watch(currentUserIdProvider);
  return LedgerNotifier(ref.watch(ledgerRepositoryProvider));
});

final accountsProvider = Provider<List<Account>>(
  (ref) => ref.watch(ledgerProvider).accounts,
);

final accountByIdProvider = Provider<Map<String, Account>>((ref) {
  return {for (final a in ref.watch(accountsProvider)) a.id: a};
});

/// Categories the user can pick for [type]: built-in ones, then active
/// custom ones by name.
final selectableCategoriesProvider =
    Provider.family<List<Category>, TransactionType>((ref, type) {
      final custom =
          ref
              .watch(ledgerProvider.select((s) => s.customCategories))
              .where((c) => c.type == type && !c.isArchived)
              .toList()
            ..sort(
              (a, b) => a.name!.toLowerCase().compareTo(b.name!.toLowerCase()),
            );
      return [...Category.systemFor(type), ...custom];
    });

/// Newest first.
final transactionsProvider = Provider<List<MoneyTransaction>>(
  (ref) => ref.watch(ledgerProvider).transactions,
);

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

/// Tapping the selected Day / Month segment again cycles its layout.
enum DayLayout { grid, list }

enum MonthLayout { calendar, list, chart }

final dayLayoutProvider = StateProvider<DayLayout>((ref) => DayLayout.grid);

final monthLayoutProvider = StateProvider<MonthLayout>(
  (ref) => MonthLayout.calendar,
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

/// Filters on the Transactions tab.
final transactionsQueryProvider = StateProvider<TransactionQuery>(
  (ref) => const TransactionQuery(),
);
