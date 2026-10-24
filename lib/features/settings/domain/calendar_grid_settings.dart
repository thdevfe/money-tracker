import 'dart:convert';

enum GridShape { rounded, circle, square }

enum GridDisplay { single, stacked, fan }

enum GridBorder { accent, none, thin }

/// How the Home calendar draws each day, plus the day monthly periods start
/// on. Saved per device.
class CalendarGridSettings {
  static const maxMonthStartDay = 28;

  final GridShape shape;
  final GridDisplay display;
  final GridBorder border;

  /// Key into the border palette; null uses the app's accent color.
  final String? borderColorKey;
  final bool showBadge;

  /// Monthly periods run from this day to the day before it next month
  /// (1 = calendar months).
  final int monthStartDay;

  const CalendarGridSettings({
    this.shape = GridShape.rounded,
    this.display = GridDisplay.stacked,
    this.border = GridBorder.accent,
    this.borderColorKey,
    this.showBadge = true,
    this.monthStartDay = 1,
  });

  CalendarGridSettings copyWith({
    GridShape? shape,
    GridDisplay? display,
    GridBorder? border,
    String? borderColorKey,
    bool autoBorderColor = false,
    bool? showBadge,
    int? monthStartDay,
  }) => CalendarGridSettings(
    shape: shape ?? this.shape,
    display: display ?? this.display,
    border: border ?? this.border,
    borderColorKey: autoBorderColor
        ? null
        : (borderColorKey ?? this.borderColorKey),
    showBadge: showBadge ?? this.showBadge,
    monthStartDay: (monthStartDay ?? this.monthStartDay).clamp(
      1,
      maxMonthStartDay,
    ),
  );

  String toJson() => jsonEncode({
    'shape': shape.name,
    'display': display.name,
    'border': border.name,
    'borderColor': borderColorKey,
    'showBadge': showBadge,
    'monthStartDay': monthStartDay,
  });

  /// Unknown or missing values fall back to defaults, so old or corrupt
  /// saved data never breaks the app.
  factory CalendarGridSettings.fromJson(String? source) {
    const defaults = CalendarGridSettings();
    if (source == null) return defaults;
    try {
      final map = jsonDecode(source) as Map<String, dynamic>;
      T pick<T extends Enum>(List<T> values, Object? name, T fallback) =>
          values.where((v) => v.name == name).firstOrNull ?? fallback;
      return CalendarGridSettings(
        shape: pick(GridShape.values, map['shape'], defaults.shape),
        display: pick(GridDisplay.values, map['display'], defaults.display),
        border: pick(GridBorder.values, map['border'], defaults.border),
        borderColorKey: map['borderColor'] as String?,
        showBadge: map['showBadge'] as bool? ?? defaults.showBadge,
        monthStartDay: ((map['monthStartDay'] as num?)?.toInt() ?? 1).clamp(
          1,
          maxMonthStartDay,
        ),
      );
    } catch (_) {
      return defaults;
    }
  }
}

/// The monthly period labelled by [month] when periods start on
/// [startDay]: `[month/startDay, nextMonth/startDay)`.
(DateTime, DateTime) monthPeriod(DateTime month, int startDay) => (
  DateTime(month.year, month.month, startDay),
  DateTime(month.year, month.month + 1, startDay),
);

/// The month label of the period containing [date].
DateTime periodMonthOf(DateTime date, int startDay) => date.day >= startDay
    ? DateTime(date.year, date.month)
    : DateTime(date.year, date.month - 1);
