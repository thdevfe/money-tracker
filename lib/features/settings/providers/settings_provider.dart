import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/calendar_grid_settings.dart';

/// Preferences kept in memory for now (theme, language, name).
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

/// `null` follows the device language. Vietnamese is the initial default.
final localeProvider = StateProvider<Locale?>((ref) => const Locale('vi'));

/// Name shown in the Home greeting; empty uses a localized default.
final profileNameProvider = StateProvider<String>((ref) => '');

/// Masks money amounts across the app (the eye toggle on Home).
final hideAmountsProvider = StateProvider<bool>((ref) => false);

/// Small key-value store for per-device preferences. In memory by default
/// (tests, previews); `main.dart` overrides it with SharedPreferences.
abstract class PreferenceStore {
  String? read(String key);
  Future<void> write(String key, String value);
}

class MemoryPreferenceStore implements PreferenceStore {
  final _values = <String, String>{};

  @override
  String? read(String key) => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;
}

final preferenceStoreProvider = Provider<PreferenceStore>(
  (ref) => MemoryPreferenceStore(),
);

/// Home calendar appearance and the monthly period start day, saved on
/// every change.
class CalendarGridSettingsNotifier extends StateNotifier<CalendarGridSettings> {
  static const _key = 'calendar_grid_settings';

  final PreferenceStore _store;

  CalendarGridSettingsNotifier(this._store)
    : super(CalendarGridSettings.fromJson(_store.read(_key)));

  void update(CalendarGridSettings settings) {
    state = settings;
    // A failed save only loses the preference, never ledger data.
    _store.write(_key, settings.toJson()).ignore();
  }
}

final calendarGridSettingsProvider =
    StateNotifierProvider<CalendarGridSettingsNotifier, CalendarGridSettings>(
      (ref) => CalendarGridSettingsNotifier(ref.watch(preferenceStoreProvider)),
    );

final monthStartDayProvider = Provider<int>(
  (ref) => ref.watch(calendarGridSettingsProvider).monthStartDay,
);
