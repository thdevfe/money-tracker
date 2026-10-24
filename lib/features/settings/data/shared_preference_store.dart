import 'package:shared_preferences/shared_preferences.dart';

import '../providers/settings_provider.dart';

/// [PreferenceStore] on the device (browser local storage on the web).
class SharedPreferenceStore implements PreferenceStore {
  final SharedPreferences _preferences;

  SharedPreferenceStore(this._preferences);

  @override
  String? read(String key) => _preferences.getString(key);

  @override
  Future<void> write(String key, String value) =>
      _preferences.setString(key, value);
}
