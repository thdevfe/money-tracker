import '../../transactions/domain/models.dart';

/// Parts of the day used to group spending times.
enum DaySlot {
  night(0), // 0–6
  morning(6), // 6–11
  noon(11), // 11–14
  afternoon(14), // 14–18
  evening(18), // 18–22
  late(22); // 22–24

  final int startHour;

  const DaySlot(this.startHour);

  static DaySlot of(DateTime t) =>
      values.lastWhere((slot) => t.hour >= slot.startHour);
}

/// Expense totals by weekday (rows, Monday first) and [DaySlot] (columns).
class SpendingHeatmap {
  /// [weekday 0..6][slot] → amount in minor units.
  final List<List<int>> amounts;
  final List<List<int>> counts;

  const SpendingHeatmap(this.amounts, this.counts);

  factory SpendingHeatmap.of(Iterable<MoneyTransaction> transactions) {
    final amounts = List.generate(
      7,
      (_) => List.filled(DaySlot.values.length, 0),
    );
    final counts = List.generate(
      7,
      (_) => List.filled(DaySlot.values.length, 0),
    );
    for (final t in transactions) {
      if (t.type != TransactionType.expense) continue;
      final row = t.occurredAt.weekday - 1;
      final col = DaySlot.of(t.occurredAt).index;
      amounts[row][col] += t.amountMinor;
      counts[row][col]++;
    }
    return SpendingHeatmap(amounts, counts);
  }

  int get max => amounts.expand((r) => r).fold(0, (m, v) => v > m ? v : m);

  bool get isEmpty => max == 0;

  /// The busiest (weekday index, slot), or null when there is no spending.
  (int, DaySlot)? get peak {
    if (isEmpty) return null;
    for (var row = 0; row < 7; row++) {
      for (final slot in DaySlot.values) {
        if (amounts[row][slot.index] == max) return (row, slot);
      }
    }
    return null;
  }
}

/// Expenses that repeat: same category and same note (case-insensitive).
class SpendingCluster {
  final Category category;

  /// The shared note; null when the entries have no note.
  final String? note;
  final int count;
  final int totalMinor;

  const SpendingCluster({
    required this.category,
    required this.note,
    required this.count,
    required this.totalMinor,
  });

  int get averageMinor => (totalMinor / count).round();
}

/// Groups of at least [minCount] matching expenses, largest total first.
List<SpendingCluster> repeatedSpending(
  Iterable<MoneyTransaction> transactions, {
  int minCount = 2,
}) {
  final groups = <String, List<MoneyTransaction>>{};
  for (final t in transactions) {
    final category = t.category;
    if (t.type != TransactionType.expense || category == null) continue;
    final note = t.note?.trim().toLowerCase() ?? '';
    groups.putIfAbsent('${category.id}|$note', () => []).add(t);
  }
  return [
    for (final items in groups.values)
      if (items.length >= minCount)
        SpendingCluster(
          category: items.first.category!,
          note: items.first.note?.trim().isEmpty ?? true
              ? null
              : items.first.note!.trim(),
          count: items.length,
          totalMinor: items.fold(0, (sum, t) => sum + t.amountMinor),
        ),
  ]..sort((a, b) => b.totalMinor.compareTo(a.totalMinor));
}
