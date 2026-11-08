import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../data/local_profile_repository.dart';
import '../domain/profile.dart';

/// Device storage by default; `main.dart` overrides it with Supabase when a
/// backend is configured.
final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => LocalProfileRepository(ref.watch(preferenceStoreProvider)),
);

/// Loads the profile and saves every change. The UI updates right away;
/// a failed save throws so the screen can say so.
class ProfileNotifier extends StateNotifier<Profile> {
  final ProfileRepository _repository;

  ProfileNotifier(this._repository) : super(const Profile()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final profile = await _repository.load();
      if (mounted) state = profile;
    } catch (_) {
      // Keep the default name and initial.
    }
  }

  Future<void> setName(String name) async {
    final trimmed = name.trim();
    state = state.copyWith(name: trimmed);
    await _repository.saveName(trimmed);
  }

  Future<void> setAvatar(Uint8List bytes) async {
    final saved = await _repository.saveAvatar(bytes, state);
    if (mounted) state = saved;
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, Profile>((ref) {
  // Reload for whoever signs in.
  ref.watch(currentUserIdProvider);
  return ProfileNotifier(ref.watch(profileRepositoryProvider));
});

/// Name shown in the Home greeting; empty uses a localized default.
final profileNameProvider = Provider<String>(
  (ref) => ref.watch(profileProvider.select((p) => p.name)),
);
