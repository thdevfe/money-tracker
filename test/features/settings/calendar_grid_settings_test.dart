import 'package:expense_tracker/features/settings/domain/calendar_grid_settings.dart';
import 'package:expense_tracker/features/settings/providers/settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('settings survive a save and load', () {
    const settings = CalendarGridSettings(
      shape: GridShape.circle,
      display: GridDisplay.fan,
      border: GridBorder.thin,
      borderColorKey: 'pink',
      showBadge: false,
      monthStartDay: 25,
    );
    final loaded = CalendarGridSettings.fromJson(settings.toJson());
    expect(loaded.shape, GridShape.circle);
    expect(loaded.display, GridDisplay.fan);
    expect(loaded.border, GridBorder.thin);
    expect(loaded.borderColorKey, 'pink');
    expect(loaded.showBadge, isFalse);
    expect(loaded.monthStartDay, 25);
  });

  test('missing or broken saved data falls back to defaults', () {
    for (final source in [null, '', '{bad json', '{"shape":"hexagon"}']) {
      final s = CalendarGridSettings.fromJson(source);
      expect(s.shape, GridShape.rounded);
      expect(s.display, GridDisplay.stacked);
      expect(s.monthStartDay, 1);
    }
    expect(
      CalendarGridSettings.fromJson('{"monthStartDay": 31}').monthStartDay,
      28,
    );
  });

  test('copyWith can reset the border color to auto', () {
    const s = CalendarGridSettings(borderColorKey: 'red');
    expect(s.copyWith(autoBorderColor: true).borderColorKey, isNull);
    expect(s.copyWith(showBadge: false).borderColorKey, 'red');
  });

  test('monthly periods start on the chosen day', () {
    final (start, end) = monthPeriod(DateTime(2026, 10), 25);
    expect(start, DateTime(2026, 10, 25));
    expect(end, DateTime(2026, 11, 25));

    // Before the start day, a date belongs to the previous month's period.
    expect(periodMonthOf(DateTime(2026, 10, 24), 25), DateTime(2026, 9));
    expect(periodMonthOf(DateTime(2026, 10, 25), 25), DateTime(2026, 10));
    expect(periodMonthOf(DateTime(2027, 1, 3), 10), DateTime(2026, 12));
    // Start day 1 is plain calendar months.
    expect(periodMonthOf(DateTime(2026, 10, 1), 1), DateTime(2026, 10));
  });

  test('the notifier saves every change to the store', () {
    final store = MemoryPreferenceStore();
    final container = ProviderContainer(
      overrides: [preferenceStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);

    container
        .read(calendarGridSettingsProvider.notifier)
        .update(const CalendarGridSettings(shape: GridShape.square));

    // A fresh notifier on the same store sees the saved value.
    final reloaded = ProviderContainer(
      overrides: [preferenceStoreProvider.overrideWithValue(store)],
    );
    addTearDown(reloaded.dispose);
    expect(reloaded.read(calendarGridSettingsProvider).shape, GridShape.square);
  });
}
