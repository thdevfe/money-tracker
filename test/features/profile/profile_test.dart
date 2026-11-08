import 'dart:typed_data';

import 'package:expense_tracker/features/profile/providers/profile_provider.dart';
import 'package:expense_tracker/features/settings/providers/settings_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ProviderContainer containerOn(PreferenceStore store) {
    final container = ProviderContainer(
      overrides: [preferenceStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('name and photo survive a reload', () async {
    final store = MemoryPreferenceStore();
    final first = containerOn(store);
    first.read(profileProvider);
    await Future<void>.delayed(Duration.zero);

    await first.read(profileProvider.notifier).setName('  Thiện ');
    await first
        .read(profileProvider.notifier)
        .setAvatar(Uint8List.fromList([1, 2, 3]));
    expect(first.read(profileNameProvider), 'Thiện');
    expect(first.read(profileProvider).avatar, isA<MemoryImage>());

    // A fresh app on the same device storage loads both back.
    final second = containerOn(store);
    second.read(profileProvider);
    await Future<void>.delayed(Duration.zero);
    expect(second.read(profileNameProvider), 'Thiện');
    expect(second.read(profileProvider).avatarBytes, [1, 2, 3]);
  });
}
