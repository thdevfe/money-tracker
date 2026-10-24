import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../features/transactions/domain/ledger.dart';
import '../../features/transactions/domain/models.dart';
import '../../l10n/app_localizations.dart';

/// Locale-aware money and date formatting. VND only for this milestone.
class Formatters {
  final String locale;
  final AppLocalizations l10n;

  /// When true, displayed amounts are masked (form input is unaffected).
  final bool hideAmounts;

  Formatters(this.locale, this.l10n, {this.hideAmounts = false});

  factory Formatters.of(BuildContext context) => Formatters(
    Localizations.localeOf(context).toLanguageTag(),
    AppLocalizations.of(context),
    hideAmounts: AmountVisibility.hiddenOf(context),
  );

  static const _minus = '−';
  static const _mask = '•••••';

  String money(int minor) => hideAmounts
      ? '$_mask ₫'
      : NumberFormat.currency(
          locale: locale,
          symbol: '₫',
          decimalDigits: 0,
        ).format(minor);

  /// Expense amounts get a minus sign and income a plus sign, so the
  /// direction never depends on color alone.
  String signedMoney(TransactionType type, int minor) => switch (type) {
    TransactionType.expense => '$_minus${money(minor)}',
    TransactionType.income => '+${money(minor)}',
    TransactionType.transfer => money(minor),
  };

  /// Short form for calendar cells, e.g. "165k" or "8tr".
  String compact(int minor) {
    if (hideAmounts) return _mask;
    final abs = minor.abs();
    final oneDecimal = NumberFormat('#,##0.#', locale);
    if (abs >= 1000000000) {
      return l10n.compactBillions(oneDecimal.format(abs / 1000000000));
    }
    if (abs >= 1000000) {
      return l10n.compactMillions(oneDecimal.format(abs / 1000000));
    }
    if (abs >= 1000) {
      return l10n.compactThousands(oneDecimal.format(abs / 1000));
    }
    return NumberFormat.decimalPattern(locale).format(abs);
  }

  String compactSigned(TransactionType type, int minor) => switch (type) {
    TransactionType.expense => '$_minus${compact(minor)}',
    TransactionType.income => '+${compact(minor)}',
    TransactionType.transfer => compact(minor),
  };

  /// Digit grouping for the amount field, e.g. "1.250.000".
  String groupDigits(int value) =>
      NumberFormat.decimalPattern(locale).format(value);

  String monthYear(DateTime month) =>
      _capitalize(DateFormat.yMMMM(locale).format(month));

  String monthShort(DateTime month) =>
      _capitalize(DateFormat.MMM(locale).format(month));

  /// Compact weekday + day + month, e.g. "Th 7, 24 thg 10".
  String dayMonth(DateTime date) =>
      _capitalize(DateFormat.MMMEd(locale).format(date));

  String fullDate(DateTime date) =>
      _capitalize(DateFormat.yMMMMEEEEd(locale).format(date));

  String shortDate(DateTime date) => DateFormat.yMd(locale).format(date);

  String weekdayShort(DateTime date) => DateFormat.E(locale).format(date);

  String time(DateTime date) => DateFormat.Hm(locale).format(date);

  /// "Today", "Yesterday", or the full date.
  String dayHeading(DateTime day, DateTime today) {
    if (isSameDay(day, today)) return l10n.today;
    if (isSameDay(day, today.subtract(const Duration(days: 1)))) {
      return l10n.yesterday;
    }
    return fullDate(day);
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

/// Provides the "hide amounts" flag to [Formatters.of].
class AmountVisibility extends InheritedWidget {
  final bool hidden;

  const AmountVisibility({
    super.key,
    required this.hidden,
    required super.child,
  });

  static bool hiddenOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AmountVisibility>()?.hidden ??
      false;

  @override
  bool updateShouldNotify(AmountVisibility oldWidget) =>
      hidden != oldWidget.hidden;
}
