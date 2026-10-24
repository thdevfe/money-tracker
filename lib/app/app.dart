import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/formatting/formatters.dart';
import '../core/theme/app_theme.dart';
import '../features/settings/providers/settings_provider.dart';
import '../l10n/app_localizations.dart';
import 'app_shell.dart';

class MoneyTrackerApp extends ConsumerWidget {
  const MoneyTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ref.watch(themeModeProvider),
      locale: ref.watch(localeProvider),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) => AmountVisibility(
        hidden: ref.watch(hideAmountsProvider),
        child: child!,
      ),
      home: const AppShell(),
    );
  }
}
