import '../../transactions/domain/models.dart';

/// A monthly spending limit, for all spending or for some categories.
class Budget {
  final String id;
  final String name;
  final int limitMinor;

  /// [Category.id]s counted against the limit; empty means all spending.
  final List<String> categoryIds;

  const Budget({
    required this.id,
    required this.name,
    required this.limitMinor,
    this.categoryIds = const [],
  });

  bool get coversAll => categoryIds.isEmpty;

  bool counts(MoneyTransaction t) =>
      t.type == TransactionType.expense &&
      (coversAll || categoryIds.contains(t.category?.id));

  /// Spending in [start, end) that counts against this budget.
  int spentMinor(
    Iterable<MoneyTransaction> transactions, {
    required DateTime start,
    required DateTime end,
  }) => transactions
      .where(
        (t) =>
            counts(t) &&
            !t.occurredAt.isBefore(start) &&
            t.occurredAt.isBefore(end),
      )
      .fold(0, (sum, t) => sum + t.amountMinor);
}

/// Storage for budgets; Supabase when configured, memory otherwise.
abstract class BudgetRepository {
  Future<List<Budget>> fetchBudgets();

  Future<Budget> saveBudget(Budget budget, {required bool isNew});

  Future<void> deleteBudget(Budget budget);
}
