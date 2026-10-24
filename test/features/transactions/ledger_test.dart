import 'package:expense_tracker/features/transactions/domain/ledger.dart';
import 'package:expense_tracker/features/transactions/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

MoneyTransaction tx(
  String id,
  TransactionType type,
  int amount, {
  DateTime? at,
  String? account,
  String? from,
  String? to,
  bool photo = false,
}) {
  return MoneyTransaction(
    id: id,
    type: type,
    amountMinor: amount,
    occurredAt: at ?? DateTime(2026, 10, 24, 12),
    accountId: account,
    sourceAccountId: from,
    destinationAccountId: to,
    photo: photo ? AssetTransactionPhoto('p/$id.jpg') : null,
  );
}

void main() {
  group('totalsOf', () {
    test('sums income and expense and ignores transfers', () {
      final totals = totalsOf([
        tx('a', TransactionType.income, 500000, account: 'cash'),
        tx('b', TransactionType.expense, 200000, account: 'cash'),
        tx('c', TransactionType.transfer, 300000, from: 'cash', to: 'bank'),
      ]);
      expect(totals.incomeMinor, 500000);
      expect(totals.expenseMinor, 200000);
      expect(totals.netMinor, 300000);
    });
  });

  group('accountBalance', () {
    test('applies opening + income - expense + transferIn - transferOut', () {
      const cash = Account(
        id: 'cash',
        name: 'Cash',
        type: AccountType.cash,
        openingBalanceMinor: 1000000,
      );
      const bank = Account(id: 'bank', name: 'Bank', type: AccountType.bank);
      final items = [
        tx('a', TransactionType.income, 500000, account: 'cash'),
        tx('b', TransactionType.expense, 200000, account: 'cash'),
        tx('c', TransactionType.transfer, 300000, from: 'cash', to: 'bank'),
      ];
      expect(accountBalance(cash, items), 1000000);
      expect(accountBalance(bank, items), 300000);
    });
  });

  group('monthGridDays', () {
    test('Monday-first grid for October 2026 starts on Sep 28', () {
      final days = monthGridDays(
        DateTime(2026, 10),
        firstWeekday: DateTime.monday,
      );
      expect(days.first, DateTime(2026, 9, 28));
      expect(days.last, DateTime(2026, 11, 1));
      expect(days.length % 7, 0);
      expect(days.where((d) => d.month == 10).length, 31);
    });

    test('Sunday-first grid for October 2026 starts on Sep 27', () {
      final days = monthGridDays(
        DateTime(2026, 10),
        firstWeekday: DateTime.sunday,
      );
      expect(days.first, DateTime(2026, 9, 27));
      expect(days.first.weekday, DateTime.sunday);
      expect(days.length, 35);
    });
  });

  test('compareNewestFirst breaks timestamp ties by id', () {
    final at = DateTime(2026, 10, 24, 9);
    final list = [
      tx('b', TransactionType.expense, 1, at: at),
      tx('old', TransactionType.expense, 1, at: DateTime(2026, 10, 1)),
      tx('a', TransactionType.expense, 1, at: at),
    ]..sort(compareNewestFirst);
    expect(list.map((t) => t.id), ['a', 'b', 'old']);
  });

  test('dayThumbnails keeps order and caps at three photos', () {
    final list = [
      tx('1', TransactionType.expense, 1, photo: true),
      tx('2', TransactionType.expense, 1),
      tx('3', TransactionType.expense, 1, photo: true),
      tx('4', TransactionType.expense, 1, photo: true),
      tx('5', TransactionType.expense, 1, photo: true),
    ];
    final thumbs = dayThumbnails(list).cast<AssetTransactionPhoto>();
    expect(thumbs.map((p) => p.assetName), ['p/1.jpg', 'p/3.jpg', 'p/4.jpg']);
  });

  test('expenseByCategory sums expenses only, largest first', () {
    MoneyTransaction e(
      String id,
      CategoryCode c,
      int amount, [
      TransactionType type = TransactionType.expense,
    ]) => MoneyTransaction(
      id: id,
      type: type,
      amountMinor: amount,
      occurredAt: DateTime(2026, 10, 1),
      category: c,
    );
    final result = expenseByCategory([
      e('1', CategoryCode.food, 100),
      e('2', CategoryCode.transport, 300),
      e('3', CategoryCode.food, 50),
      e('4', CategoryCode.salary, 9999, TransactionType.income),
    ]);
    expect(result.map((r) => r.category), [
      CategoryCode.transport,
      CategoryCode.food,
    ]);
    expect(result.last.amountMinor, 150);
    expect(result.last.count, 2);
  });

  test('savingsRate is null without income', () {
    expect(savingsRate(const PeriodTotals()), isNull);
    expect(
      savingsRate(const PeriodTotals(incomeMinor: 1000, expenseMinor: 750)),
      0.25,
    );
  });
}
