/// A bank term deposit. Tracked on its own: it does not change account
/// balances. Interest is simple interest over the term, as Vietnamese
/// banks quote it (yearly rate, 365-day year).
class TermDeposit {
  final String id;
  final String bankName;
  final int principalMinor;

  /// Yearly rate in basis points: 550 = 5.5%/year.
  final int rateBasisPoints;
  final DateTime startDate;
  final int termMonths;

  const TermDeposit({
    required this.id,
    required this.bankName,
    required this.principalMinor,
    required this.rateBasisPoints,
    required this.startDate,
    required this.termMonths,
  });

  double get ratePercent => rateBasisPoints / 100;

  /// Same day of the month [termMonths] later (clamped to the month's end).
  DateTime get maturityDate {
    final target = DateTime(startDate.year, startDate.month + termMonths);
    final lastDay = DateTime(target.year, target.month + 1, 0).day;
    final day = startDate.day > lastDay ? lastDay : startDate.day;
    return DateTime(target.year, target.month, day);
  }

  int get termDays => maturityDate.difference(_day(startDate)).inDays;

  int _interestForDays(int days) =>
      (principalMinor * rateBasisPoints * days / (10000 * 365)).round();

  /// Interest paid at maturity.
  int get interestAtMaturityMinor => _interestForDays(termDays);

  /// Interest earned so far on [today] (none before the start, all of it
  /// from maturity on).
  int accruedInterestMinor(DateTime today) {
    final elapsed = _day(today).difference(_day(startDate)).inDays;
    return _interestForDays(elapsed.clamp(0, termDays));
  }

  /// 0..1 through the term on [today].
  double progress(DateTime today) {
    if (termDays <= 0) return 1;
    final elapsed = _day(today).difference(_day(startDate)).inDays;
    return (elapsed / termDays).clamp(0, 1).toDouble();
  }

  bool isMatured(DateTime today) => !_day(today).isBefore(maturityDate);

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);
}

/// Storage for term deposits; Supabase when configured, memory otherwise.
abstract class DepositRepository {
  Future<List<TermDeposit>> fetchDeposits();

  /// Creates (when [isNew]) or updates [deposit]; returns the stored one.
  Future<TermDeposit> saveDeposit(TermDeposit deposit, {required bool isNew});

  Future<void> deleteDeposit(TermDeposit deposit);
}
