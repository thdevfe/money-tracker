import 'package:expense_tracker/features/reports/domain/spending_patterns.dart';
import 'package:expense_tracker/features/transactions/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

MoneyTransaction tx(
  String id,
  DateTime at,
  int amount, {
  CategoryCode code = CategoryCode.food,
  String? note,
  TransactionType type = TransactionType.expense,
}) => MoneyTransaction(
  id: id,
  type: type,
  amountMinor: amount,
  occurredAt: at,
  accountId: 'cash',
  category: Category.system(code),
  note: note,
);

void main() {
  test('day slots split the day', () {
    expect(DaySlot.of(DateTime(2026, 1, 1, 5, 59)), DaySlot.night);
    expect(DaySlot.of(DateTime(2026, 1, 1, 6)), DaySlot.morning);
    expect(DaySlot.of(DateTime(2026, 1, 1, 12)), DaySlot.noon);
    expect(DaySlot.of(DateTime(2026, 1, 1, 15)), DaySlot.afternoon);
    expect(DaySlot.of(DateTime(2026, 1, 1, 19)), DaySlot.evening);
    expect(DaySlot.of(DateTime(2026, 1, 1, 23)), DaySlot.late);
  });

  test('the heatmap sums expenses by weekday and slot', () {
    // 2026-10-24 is a Saturday.
    final map = SpendingHeatmap.of([
      tx('a', DateTime(2026, 10, 24, 19), 100),
      tx('b', DateTime(2026, 10, 24, 20), 50),
      tx('c', DateTime(2026, 10, 19, 8), 30), // Monday morning
      tx('d', DateTime(2026, 10, 24, 19), 999, type: TransactionType.income),
    ]);
    expect(map.amounts[5][DaySlot.evening.index], 150);
    expect(map.counts[5][DaySlot.evening.index], 2);
    expect(map.amounts[0][DaySlot.morning.index], 30);
    expect(map.peak, (5, DaySlot.evening));
    expect(SpendingHeatmap.of(const []).peak, isNull);
  });

  test('repeats group by category and note, ignoring case', () {
    final clusters = repeatedSpending([
      tx('a', DateTime(2026, 10, 1, 8), 35000, note: 'Cà phê'),
      tx('b', DateTime(2026, 10, 2, 8), 40000, note: 'cà phê '),
      tx('c', DateTime(2026, 10, 3, 8), 30000, note: 'Phở'),
      tx('d', DateTime(2026, 10, 4, 9), 60000, code: CategoryCode.transport),
      tx('e', DateTime(2026, 10, 5, 9), 60000, code: CategoryCode.transport),
    ]);
    expect(clusters, hasLength(2));
    expect(clusters.first.category.code, CategoryCode.transport);
    expect(clusters.first.note, isNull);
    expect(clusters.last.note, 'Cà phê');
    expect(clusters.last.count, 2);
    expect(clusters.last.averageMinor, 37500);
  });
}
