import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Demo-only preferences kept in memory for this prototype.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

/// `null` follows the device language. Vietnamese is the initial default.
final localeProvider = StateProvider<Locale?>((ref) => const Locale('vi'));

/// Name shown in the Home greeting; empty uses a localized default.
final profileNameProvider = StateProvider<String>((ref) => '');

/// Masks money amounts across the app (the eye toggle on Home).
final hideAmountsProvider = StateProvider<bool>((ref) => false);
