import 'package:expense_tracker/features/transactions/data/mock_data.dart';
import 'package:expense_tracker/features/transactions/domain/ledger.dart';
import 'package:expense_tracker/features/transactions/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final anchor = DateTime(2026, 10, 24, 20);

  test('is deterministic for the same anchor', () {
    String signature(List<MoneyTransaction> items) => items
        .map((t) => '${t.id}|${t.amountMinor}|${t.occurredAt}|${t.note}')
        .join(';');
    expect(
      signature(buildMockTransactions(anchor)),
      signature(buildMockTransactions(anchor)),
    );
  });

  test('has no transactions after the anchor day', () {
    final items = buildMockTransactions(anchor);
    expect(
      items.every((t) => !t.occurredAt.isAfter(DateTime(2026, 10, 25))),
      isTrue,
    );
  });

  test('places the documented fixtures on the anchor day', () {
    final today = buildMockTransactions(
      anchor,
    ).where((t) => isSameDay(t.occurredAt, anchor)).toList();
    expect(today.map((t) => t.note), ['Cà phê', 'Grab', 'Ăn trưa', 'Mua sắm']);
    expect(today.map((t) => t.hasPhoto), [true, true, true, false]);
    expect(today.map((t) => t.amountMinor), [55000, 60000, 85000, 165000]);
  });

  test('day 1 is income only and day 2 is a transfer', () {
    final items = buildMockTransactions(anchor);
    final day1 = items.where(
      (t) => isSameDay(t.occurredAt, DateTime(2026, 10, 1)),
    );
    final day2 = items.where(
      (t) => isSameDay(t.occurredAt, DateTime(2026, 10, 2)),
    );
    expect(day1.single.type, TransactionType.income);
    expect(day1.single.amountMinor, 8000000);
    expect(day2.single.type, TransactionType.transfer);
  });

  test('day 6 has more photos than a calendar cell shows', () {
    final day6 = buildMockTransactions(
      anchor,
    ).where((t) => isSameDay(t.occurredAt, DateTime(2026, 10, 6)));
    expect(day6.where((t) => t.hasPhoto).length, greaterThan(3));
  });
}
