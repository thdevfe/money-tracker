import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Demo-only preferences kept in memory for this prototype.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// `null` follows the device language. Vietnamese is the initial default.
final localeProvider = StateProvider<Locale?>((ref) => const Locale('vi'));
