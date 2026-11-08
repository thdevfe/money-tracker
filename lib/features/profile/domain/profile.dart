import 'dart:typed_data';

import 'package:flutter/widgets.dart';

/// The user's display name and photo. An empty [name] shows the localized
/// default.
class Profile {
  final String name;

  /// Photo bytes kept on the device (demo mode).
  final Uint8List? avatarBytes;

  /// Signed URL of the photo in cloud storage.
  final String? avatarUrl;

  const Profile({this.name = '', this.avatarBytes, this.avatarUrl});

  ImageProvider? get avatar {
    final bytes = avatarBytes;
    if (bytes != null) return MemoryImage(bytes);
    final url = avatarUrl;
    return url == null ? null : NetworkImage(url);
  }

  Profile copyWith({String? name}) => Profile(
    name: name ?? this.name,
    avatarBytes: avatarBytes,
    avatarUrl: avatarUrl,
  );
}

abstract class ProfileRepository {
  Future<Profile> load();

  Future<void> saveName(String name);

  /// Stores a new photo (a small JPEG) and returns the updated profile.
  Future<Profile> saveAvatar(Uint8List bytes, Profile current);
}
