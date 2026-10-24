import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    Widget section(String title, Widget child) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navProfile)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.navClearance,
        ),
        children: [
          section(
            l10n.profileName,
            TextFormField(
              initialValue: ref.read(profileNameProvider),
              textCapitalization: TextCapitalization.words,
              maxLength: 40,
              decoration: InputDecoration(
                hintText: l10n.defaultUserName,
                counterText: '',
                prefixIcon: const Icon(Icons.person_outline_rounded),
              ),
              onChanged: (v) =>
                  ref.read(profileNameProvider.notifier).state = v,
            ),
          ),
          section(
            l10n.settingsAppearance,
            SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: const Icon(Icons.brightness_auto_rounded),
                  label: Text(l10n.themeSystem),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: const Icon(Icons.light_mode_rounded),
                  label: Text(l10n.themeLight),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: const Icon(Icons.dark_mode_rounded),
                  label: Text(l10n.themeDark),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (v) =>
                  ref.read(themeModeProvider.notifier).state = v.first,
            ),
          ),
          section(
            l10n.settingsLanguage,
            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: '', label: Text(l10n.languageSystem)),
                ButtonSegment(
                  value: 'vi',
                  label: Text(l10n.languageVietnamese),
                ),
                ButtonSegment(value: 'en', label: Text(l10n.languageEnglish)),
              ],
              selected: {locale?.languageCode ?? ''},
              onSelectionChanged: (v) =>
                  ref.read(localeProvider.notifier).state = v.first.isEmpty
                  ? null
                  : Locale(v.first),
            ),
          ),
          section(
            l10n.settingsCurrency,
            Card(
              child: ListTile(
                leading: const Icon(Icons.payments_outlined),
                title: Text(l10n.currencyVnd),
              ),
            ),
          ),
          section(
            l10n.settingsData,
            Card(
              child: ListTile(
                leading: const Icon(Icons.phone_iphone_rounded),
                title: Text(
                  l10n.dataPrototypeNote,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
