import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/profile.dart';

/// The name lives in the account's user metadata so it follows the user
/// across devices; the photo is a file in their private storage folder.
class SupabaseProfileRepository implements ProfileRepository {
  static const _bucket = 'transaction-photos';
  static const _nameKey = 'display_name';
  static const _avatarKey = 'avatar_path';

  final SupabaseClient _client;

  SupabaseProfileRepository(this._client);

  Map<String, dynamic> get _metadata =>
      _client.auth.currentUser?.userMetadata ?? const {};

  @override
  Future<Profile> load() async {
    final path = _metadata[_avatarKey] as String?;
    String? url;
    if (path != null) {
      try {
        url = await _client.storage
            .from(_bucket)
            .createSignedUrl(path, 60 * 60 * 24);
      } catch (_) {
        // A missing photo just shows the initial.
      }
    }
    return Profile(name: _metadata[_nameKey] as String? ?? '', avatarUrl: url);
  }

  @override
  Future<void> saveName(String name) =>
      _client.auth.updateUser(UserAttributes(data: {_nameKey: name}));

  @override
  Future<Profile> saveAvatar(Uint8List bytes, Profile current) async {
    final userId = _client.auth.currentUser!.id;
    final previous = _metadata[_avatarKey] as String?;
    // A new name per upload: the storage policies allow insert, not update.
    final path = '$userId/avatar-${DateTime.now().millisecondsSinceEpoch}.jpg';
    final storage = _client.storage.from(_bucket);
    await storage.uploadBinary(
      path,
      bytes,
      fileOptions: const FileOptions(contentType: 'image/jpeg'),
    );
    await _client.auth.updateUser(UserAttributes(data: {_avatarKey: path}));
    if (previous != null) {
      try {
        await storage.remove([previous]);
      } catch (_) {
        // An orphaned old photo is harmless.
      }
    }
    final url = await storage.createSignedUrl(path, 60 * 60 * 24);
    return Profile(name: current.name, avatarUrl: url);
  }
}
