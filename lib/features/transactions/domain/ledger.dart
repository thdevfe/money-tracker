import 'models.dart';

/// Pure calculations over a list of transactions. Amounts are integer minor
/// units; transfers never count as income or expense.

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime monthStart(DateTime d) => DateTime(d.year, d.month);

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

bool isSameMonth(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month;

class PeriodTotals {
  final int incomeMinor;
  final int expenseMinor;

  const PeriodTotals({this.incomeMinor = 0, this.expenseMinor = 0});

  int get netMinor => incomeMinor - expenseMinor;
}

PeriodTotals totalsOf(Iterable<MoneyTransaction> transactions) {
  var income = 0;
  var expense = 0;
  for (final t in transactions) {
    switch (t.type) {
      case TransactionType.income:
        income += t.amountMinor;
      case TransactionType.expense:
        expense += t.amountMinor;
      case TransactionType.transfer:
        break;
    }
  }
  return PeriodTotals(incomeMinor: income, expenseMinor: expense);
}

/// Newest first, then by id so equal timestamps sort deterministically.
int compareNewestFirst(MoneyTransaction a, MoneyTransaction b) {
  final byTime = b.occurredAt.compareTo(a.occurredAt);
  return byTime != 0 ? byTime : a.id.compareTo(b.id);
}

/// balance = opening + income - expense + transferIn - transferOut
int accountBalance(Account account, Iterable<MoneyTransaction> transactions) {
  var balance = account.openingBalanceMinor;
  for (final t in transactions) {
    switch (t.type) {
      case TransactionType.income when t.accountId == account.id:
        balance += t.amountMinor;
      case TransactionType.expense when t.accountId == account.id:
        balance -= t.amountMinor;
      case TransactionType.transfer:
        if (t.destinationAccountId == account.id) balance += t.amountMinor;
        if (t.sourceAccountId == account.id) balance -= t.amountMinor;
      default:
        break;
    }
  }
  return balance;
}

/// The cells of a month grid: whole weeks starting on [firstWeekday]
/// (DateTime.monday..DateTime.sunday), including leading/trailing days of the
/// adjacent months.
List<DateTime> monthGridDays(DateTime month, {required int firstWeekday}) {
  final first = monthStart(month);
  final leading = (first.weekday - firstWeekday + 7) % 7;
  final daysInMonth = DateTime(first.year, first.month + 1, 0).day;
  final cellCount = ((leading + daysInMonth) / 7).ceil() * 7;
  return [
    for (var i = 0; i < cellCount; i++)
      DateTime(first.year, first.month, 1 - leading + i),
  ];
}

/// Photos to show for a day, newest first. Returns at most [max] photos.
List<TransactionPhoto> dayThumbnails(
  List<MoneyTransaction> dayTransactionsNewestFirst, {
  int max = 3,
}) {
  return dayTransactionsNewestFirst
      .where((t) => t.photo != null)
      .map((t) => t.photo!)
      .take(max)
      .toList();
}
