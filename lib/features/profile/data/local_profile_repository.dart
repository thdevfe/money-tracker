import 'dart:convert';
import 'dart:typed_data';

import '../../settings/providers/settings_provider.dart';
import '../domain/profile.dart';

/// Keeps the profile in the device's preferences (demo mode).
class LocalProfileRepository implements ProfileRepository {
  static const _nameKey = 'profile_name';
  static const _avatarKey = 'profile_avatar';

  final PreferenceStore _store;

  LocalProfileRepository(this._store);

  @override
  Future<Profile> load() async {
    final avatar = _store.read(_avatarKey);
    return Profile(
      name: _store.read(_nameKey) ?? '',
      avatarBytes: avatar == null ? null : base64Decode(avatar),
    );
  }

  @override
  Future<void> saveName(String name) => _store.write(_nameKey, name);

  @override
  Future<Profile> saveAvatar(Uint8List bytes, Profile current) async {
    await _store.write(_avatarKey, base64Encode(bytes));
    return Profile(name: current.name, avatarBytes: bytes);
  }
}
