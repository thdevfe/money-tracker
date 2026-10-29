import '../domain/budget.dart';

class InMemoryBudgetRepository implements BudgetRepository {
  final Map<String, Budget> _budgets;

  InMemoryBudgetRepository([List<Budget> budgets = const []])
    : _budgets = {for (final b in budgets) b.id: b};

  @override
  Future<List<Budget>> fetchBudgets() async => _budgets.values.toList();

  @override
  Future<Budget> saveBudget(Budget budget, {required bool isNew}) async =>
      _budgets[budget.id] = budget;

  @override
  Future<void> deleteBudget(Budget budget) async => _budgets.remove(budget.id);
}
