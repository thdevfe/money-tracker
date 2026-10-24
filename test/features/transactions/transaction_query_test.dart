import 'package:expense_tracker/features/transactions/domain/models.dart';
import 'package:expense_tracker/features/transactions/domain/transaction_query.dart';
import 'package:flutter_test/flutter_test.dart';

final now = DateTime(2026, 10, 25, 9);

MoneyTransaction tx(
  String id,
  DateTime at, {
  TransactionType type = TransactionType.expense,
  String? account = 'cash',
  CategoryCode category = CategoryCode.food,
  String? from,
  String? to,
  String? note,
}) {
  final isTransfer = type == TransactionType.transfer;
  return MoneyTransaction(
    id: id,
    type: type,
    amountMinor: 1000,
    occurredAt: at,
    accountId: isTransfer ? null : account,
    category: isTransfer ? null : Category.system(category),
    sourceAccountId: from,
    destinationAccountId: to,
    note: note,
  );
}

void main() {
  test('an empty query matches everything and is not filtered', () {
    const q = TransactionQuery();
    expect(q.isFiltered, isFalse);
    expect(q.matches(tx('1', DateTime(2020)), now: now), isTrue);
  });

  test('this month uses local calendar boundaries, end exclusive', () {
    const q = TransactionQuery(period: PeriodPreset.thisMonth);
    expect(q.matches(tx('1', DateTime(2026, 10, 1)), now: now), isTrue);
    expect(
      q.matches(tx('2', DateTime(2026, 10, 31, 23, 59)), now: now),
      isTrue,
    );
    expect(q.matches(tx('3', DateTime(2026, 11, 1)), now: now), isFalse);
    expect(
      q.matches(tx('4', DateTime(2026, 9, 30, 23, 59)), now: now),
      isFalse,
    );
  });

  test('last month crosses the year boundary', () {
    const q = TransactionQuery(period: PeriodPreset.lastMonth);
    final january = DateTime(2027, 1, 10);
    expect(q.matches(tx('1', DateTime(2026, 12, 31)), now: january), isTrue);
    expect(q.matches(tx('2', DateTime(2027, 1, 1)), now: january), isFalse);
  });

  test('custom range includes both chosen days', () {
    final q = TransactionQuery(
      period: PeriodPreset.custom,
      customStart: DateTime(2026, 10, 5),
      customEnd: DateTime(2026, 10, 6),
    );
    expect(q.matches(tx('1', DateTime(2026, 10, 5)), now: now), isTrue);
    expect(q.matches(tx('2', DateTime(2026, 10, 6, 23)), now: now), isTrue);
    expect(q.matches(tx('3', DateTime(2026, 10, 7)), now: now), isFalse);
  });

  test('account filter includes transfers in and out', () {
    const q = TransactionQuery(accountId: 'bank');
    final at = DateTime(2026, 10, 2);
    expect(q.matches(tx('1', at, account: 'bank'), now: now), isTrue);
    expect(q.matches(tx('2', at, account: 'cash'), now: now), isFalse);
    expect(
      q.matches(
        tx('3', at, type: TransactionType.transfer, from: 'bank', to: 'cash'),
        now: now,
      ),
      isTrue,
    );
    expect(
      q.matches(
        tx('4', at, type: TransactionType.transfer, from: 'cash', to: 'bank'),
        now: now,
      ),
      isTrue,
    );
  });

  test('filters combine', () {
    final q = const TransactionQuery(
      type: TypeFilter.expense,
      accountId: 'cash',
    ).copyWith(categoryId: 'transport', period: PeriodPreset.thisMonth);
    final at = DateTime(2026, 10, 3);
    expect(
      q.matches(tx('1', at, category: CategoryCode.transport), now: now),
      isTrue,
    );
    expect(
      q.matches(tx('2', at, category: CategoryCode.food), now: now),
      isFalse,
    );
    expect(
      q.matches(
        tx('3', at, category: CategoryCode.transport, account: 'bank'),
        now: now,
      ),
      isFalse,
    );
    expect(q.isFiltered, isTrue);
    expect(
      q.copyWith(clearAccount: true, clearCategory: true).accountId,
      isNull,
    );
  });

  test('search uses the provided text, ignoring case', () {
    const q = TransactionQuery(search: 'PHỞ');
    final at = DateTime(2026, 10, 3);
    expect(q.matches(tx('1', at, note: 'Ăn phở'), now: now), isTrue);
    expect(
      q.matches(
        tx('2', at, note: 'Lunch'),
        now: now,
        searchText: (_) => 'lunch ăn uống phở',
      ),
      isTrue,
    );
    expect(q.matches(tx('3', at, note: 'Lunch'), now: now), isFalse);
  });
}
