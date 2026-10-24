import 'ledger.dart';
import 'models.dart';

enum TypeFilter { all, expense, income, transfer }

enum PeriodPreset { anyTime, thisMonth, lastMonth, custom }

/// History filters. Every set filter must match (they combine with AND).
/// Dates use local calendar days with a half-open range:
/// `start <= occurredAt < endExclusive`.
class TransactionQuery {
  final TypeFilter type;
  final PeriodPreset period;

  /// Inclusive first and last day for [PeriodPreset.custom].
  final DateTime? customStart;
  final DateTime? customEnd;

  /// Matches the account, transfer source or transfer destination.
  final String? accountId;
  final String? categoryId;
  final String search;

  const TransactionQuery({
    this.type = TypeFilter.all,
    this.period = PeriodPreset.anyTime,
    this.customStart,
    this.customEnd,
    this.accountId,
    this.categoryId,
    this.search = '',
  });

  /// True when anything narrows the list (used to show "reset").
  bool get isFiltered =>
      type != TypeFilter.all ||
      period != PeriodPreset.anyTime ||
      accountId != null ||
      categoryId != null ||
      search.trim().isNotEmpty;

  TransactionQuery copyWith({
    TypeFilter? type,
    PeriodPreset? period,
    DateTime? customStart,
    DateTime? customEnd,
    String? accountId,
    bool clearAccount = false,
    String? categoryId,
    bool clearCategory = false,
    String? search,
  }) => TransactionQuery(
    type: type ?? this.type,
    period: period ?? this.period,
    customStart: customStart ?? this.customStart,
    customEnd: customEnd ?? this.customEnd,
    accountId: clearAccount ? null : (accountId ?? this.accountId),
    categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
    search: search ?? this.search,
  );

  /// The period as `[start, endExclusive)` relative to [now], or null for
  /// any time.
  (DateTime, DateTime)? range(DateTime now) {
    final month = monthStart(now);
    return switch (period) {
      PeriodPreset.anyTime => null,
      PeriodPreset.thisMonth => (month, DateTime(month.year, month.month + 1)),
      PeriodPreset.lastMonth => (DateTime(month.year, month.month - 1), month),
      PeriodPreset.custom =>
        customStart == null || customEnd == null
            ? null
            : (
                dateOnly(customStart!),
                DateTime(customEnd!.year, customEnd!.month, customEnd!.day + 1),
              ),
    };
  }

  /// [searchText] supplies the localized words to search in (note,
  /// category label, account names).
  bool matches(
    MoneyTransaction t, {
    required DateTime now,
    String Function(MoneyTransaction)? searchText,
  }) {
    final typeOk = switch (type) {
      TypeFilter.all => true,
      TypeFilter.expense => t.type == TransactionType.expense,
      TypeFilter.income => t.type == TransactionType.income,
      TypeFilter.transfer => t.type == TransactionType.transfer,
    };
    if (!typeOk) return false;

    final r = range(now);
    if (r != null &&
        (t.occurredAt.isBefore(r.$1) || !t.occurredAt.isBefore(r.$2))) {
      return false;
    }

    final account = accountId;
    if (account != null && !involvesAccount(t, account)) return false;

    if (categoryId != null && t.category?.id != categoryId) return false;

    final query = search.trim().toLowerCase();
    if (query.isNotEmpty) {
      final text = searchText?.call(t) ?? t.note ?? '';
      if (!text.toLowerCase().contains(query)) return false;
    }
    return true;
  }
}
