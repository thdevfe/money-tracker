import 'dart:math';

import '../domain/models.dart';

/// Fictional, deterministic sample data for the UI prototype. Nothing here is
/// persisted; it is rebuilt from [anchor] (normally "now") on every launch.

const cashAccountId = 'acc-cash';
const bankAccountId = 'acc-bank';

const mockAccounts = [
  Account(
    id: cashAccountId,
    name: 'Ví tiền mặt',
    type: AccountType.cash,
    openingBalanceMinor: 2450000,
  ),
  Account(
    id: bankAccountId,
    name: 'Vietcombank',
    type: AccountType.bank,
    openingBalanceMinor: 8000000,
  ),
];

const _photoDir = 'assets/mock_photos';

class _Template {
  final String note;
  final CategoryCode category;
  final int minK;
  final int maxK;
  final String? photo;
  final String accountId;

  const _Template(
    this.note,
    this.category,
    this.minK,
    this.maxK, {
    this.photo,
    this.accountId = cashAccountId,
  });
}

const _templates = [
  _Template('Cà phê', CategoryCode.food, 35, 65, photo: 'coffee'),
  _Template('Trà sữa', CategoryCode.food, 40, 60, photo: 'milk_tea'),
  _Template('Bánh mì', CategoryCode.food, 20, 35, photo: 'banh_mi'),
  _Template('Ăn trưa', CategoryCode.food, 50, 95, photo: 'noodle_bowl'),
  _Template('Grab', CategoryCode.transport, 30, 90, photo: 'car_ride'),
  _Template('Đi chợ', CategoryCode.food, 120, 300, photo: 'fruit_basket'),
  _Template(
    'Pizza tối',
    CategoryCode.food,
    150,
    250,
    photo: 'pizza',
    accountId: bankAccountId,
  ),
  _Template('Đổ xăng', CategoryCode.transport, 60, 100),
  _Template(
    'Mua sắm',
    CategoryCode.shopping,
    100,
    400,
    accountId: bankAccountId,
  ),
  _Template(
    'Xem phim',
    CategoryCode.entertainment,
    90,
    180,
    accountId: bankAccountId,
  ),
  _Template('Thuốc', CategoryCode.health, 40, 150),
];

TransactionPhoto _photo(String name) =>
    AssetTransactionPhoto('$_photoDir/$name.jpg');

/// Builds sample transactions for the month of [anchor] (up to and including
/// the anchor day) and the whole previous month.
List<MoneyTransaction> buildMockTransactions(DateTime anchor) {
  final current = DateTime(anchor.year, anchor.month);
  final previous = DateTime(anchor.year, anchor.month - 1);
  return [
    ..._monthTransactions(previous, lastDay: _daysIn(previous)),
    ..._monthTransactions(current, lastDay: anchor.day),
  ];
}

int _daysIn(DateTime month) => DateTime(month.year, month.month + 1, 0).day;

List<MoneyTransaction> _monthTransactions(
  DateTime month, {
  required int lastDay,
}) {
  final result = <MoneyTransaction>[];
  final prefix = 'mock-${month.year}-${month.month}';
  DateTime at(int day, int hour, int minute) =>
      DateTime(month.year, month.month, day, hour, minute);

  for (var day = 1; day <= lastDay; day++) {
    var seq = 0;
    String nextId() => '$prefix-$day-${seq++}';

    // Day 1: salary only, so the calendar shows an income-only day.
    if (day == 1) {
      result.add(
        MoneyTransaction(
          id: nextId(),
          type: TransactionType.income,
          amountMinor: 8000000,
          occurredAt: at(day, 9, 0),
          accountId: bankAccountId,
          category: Category.system(CategoryCode.salary),
          note: 'Lương',
        ),
      );
      continue;
    }

    // Day 2: ATM withdrawal (transfer, excluded from income/expense).
    if (day == 2) {
      result.add(
        MoneyTransaction(
          id: nextId(),
          type: TransactionType.transfer,
          amountMinor: 2000000,
          occurredAt: at(day, 18, 10),
          sourceAccountId: bankAccountId,
          destinationAccountId: cashAccountId,
          note: 'Rút tiền ATM',
        ),
      );
      continue;
    }

    // Day 10: a bill with a receipt photo.
    if (day == 10) {
      result.add(
        MoneyTransaction(
          id: nextId(),
          type: TransactionType.expense,
          amountMinor: 615000,
          occurredAt: at(day, 20, 0),
          accountId: bankAccountId,
          category: Category.system(CategoryCode.bills),
          note: 'Tiền điện',
          photo: _photo('receipt'),
        ),
      );
    }

    // Day 6: a busy day that overflows the calendar cell.
    final busy = day == 6;
    final random = Random(month.year * 10000 + month.month * 100 + day);
    if (!busy && day != 10 && random.nextInt(10) < 3) continue;

    final count = busy ? 7 : 1 + random.nextInt(3);
    var hour = 7 + random.nextInt(2);
    final picked = <int>{};
    for (var i = 0; i < count; i++) {
      var index = random.nextInt(_templates.length);
      while (busy && !picked.add(index) && picked.length < _templates.length) {
        index = random.nextInt(_templates.length);
      }
      final t = _templates[index];
      final steps = (t.maxK - t.minK) ~/ 5;
      final amountK = t.minK + 5 * random.nextInt(steps + 1);
      result.add(
        MoneyTransaction(
          id: nextId(),
          type: TransactionType.expense,
          amountMinor: amountK * 1000,
          occurredAt: at(day, hour, random.nextInt(4) * 15),
          accountId: t.accountId,
          category: Category.system(t.category),
          note: t.note,
          photo: t.photo == null ? null : _photo(t.photo!),
        ),
      );
      hour = min(22, hour + 2 + random.nextInt(3));
    }
  }

  // The documented fixtures, placed on the most recent day of the period.
  if (lastDay > 2) {
    result.removeWhere((t) => t.id.startsWith('$prefix-$lastDay-'));
    var seq = 0;
    MoneyTransaction expense(
      String note,
      CategoryCode category,
      int amount,
      int hour,
      int minute, {
      String? photo,
    }) {
      return MoneyTransaction(
        id: '$prefix-$lastDay-${seq++}',
        type: TransactionType.expense,
        amountMinor: amount,
        occurredAt: at(lastDay, hour, minute),
        accountId: cashAccountId,
        category: Category.system(category),
        note: note,
        photo: photo == null ? null : _photo(photo),
      );
    }

    result.addAll([
      expense('Cà phê', CategoryCode.food, 55000, 8, 15, photo: 'coffee'),
      expense('Grab', CategoryCode.transport, 60000, 8, 45, photo: 'car_ride'),
      expense(
        'Ăn trưa',
        CategoryCode.food,
        85000,
        12,
        10,
        photo: 'noodle_bowl',
      ),
      expense('Mua sắm', CategoryCode.shopping, 165000, 17, 30),
    ]);
  }
  return result;
}
