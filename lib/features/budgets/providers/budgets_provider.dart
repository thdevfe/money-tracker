import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/domain/calendar_grid_settings.dart';
import '../../settings/providers/settings_provider.dart';
import '../../transactions/providers/transactions_provider.dart';
import '../data/in_memory_budget_repository.dart';
import '../domain/budget.dart';

/// In memory by default (demo mode, tests); `main.dart` overrides it with
/// Supabase when a backend is configured.
final budgetRepositoryProvider = Provider<BudgetRepository>(
  (ref) => InMemoryBudgetRepository(),
);

/// The user's budgets in creation order. Changes are saved first.
class BudgetsNotifier extends StateNotifier<AsyncValue<List<Budget>>> {
  final BudgetRepository _repository;

  BudgetsNotifier(this._repository) : super(const AsyncLoading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncLoading();
    try {
      final budgets = await _repository.fetchBudgets();
      if (mounted) state = AsyncData(budgets);
    } catch (e, stack) {
      if (mounted) state = AsyncError(e, stack);
    }
  }

  List<Budget> get _current => state.valueOrNull ?? const [];

  Future<void> save(Budget budget) async {
    final isNew = !_current.any((b) => b.id == budget.id);
    final saved = await _repository.saveBudget(budget, isNew: isNew);
    if (!mounted) return;
    state = AsyncData(
      isNew
          ? [..._current, saved]
          : [for (final b in _current) b.id == saved.id ? saved : b],
    );
  }

  Future<void> delete(Budget budget) async {
    await _repository.deleteBudget(budget);
    if (!mounted) return;
    state = AsyncData([
      for (final b in _current)
        if (b.id != budget.id) b,
    ]);
  }
}

final budgetsProvider =
    StateNotifierProvider<BudgetsNotifier, AsyncValue<List<Budget>>>(
      (ref) => BudgetsNotifier(ref.watch(budgetRepositoryProvider)),
    );

/// The current monthly period [start, end), honoring the month start day.
final budgetPeriodProvider = Provider<(DateTime, DateTime)>((ref) {
  final startDay = ref.watch(monthStartDayProvider);
  final today = ref.watch(clockProvider)();
  return monthPeriod(periodMonthOf(today, startDay), startDay);
});
