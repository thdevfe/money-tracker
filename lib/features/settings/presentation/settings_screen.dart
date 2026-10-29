import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/navigation.dart';
import '../../../core/formatting/formatters.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import '../../transactions/domain/ledger.dart';
import '../../transactions/providers/transactions_provider.dart';
import '../providers/settings_provider.dart';
import 'customize_grid_sheet.dart';

/// Profile card with totals, then tools, preferences and account settings
/// in grouped lists.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final auth = ref.watch(authServiceProvider);
    ref.watch(currentUserIdProvider);

    final themeLabel = switch (themeMode) {
      ThemeMode.system => l10n.themeSystem,
      ThemeMode.light => l10n.themeLight,
      ThemeMode.dark => l10n.themeDark,
    };
    final languageLabel = switch (locale?.languageCode) {
      'vi' => l10n.languageVietnamese,
      'en' => l10n.languageEnglish,
      _ => l10n.languageSystem,
    };

    Future<void> pickTheme() async {
      final picked = await _pickOption(context, l10n.settingsAppearance, {
        ThemeMode.system: (Icons.brightness_auto_rounded, l10n.themeSystem),
        ThemeMode.light: (Icons.light_mode_rounded, l10n.themeLight),
        ThemeMode.dark: (Icons.dark_mode_rounded, l10n.themeDark),
      }, themeMode);
      if (picked != null) ref.read(themeModeProvider.notifier).state = picked;
    }

    Future<void> pickLanguage() async {
      final picked = await _pickOption(context, l10n.settingsLanguage, {
        '': (Icons.phone_iphone_rounded, l10n.languageSystem),
        'vi': (Icons.translate_rounded, l10n.languageVietnamese),
        'en': (Icons.language_rounded, l10n.languageEnglish),
      }, locale?.languageCode ?? '');
      if (picked == null) return;
      ref.read(localeProvider.notifier).state = picked.isEmpty
          ? null
          : Locale(picked);
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.navClearance,
          ),
          children: [
            const _ProfileCard(),
            _Section(
              title: l10n.sectionTools,
              tiles: [
                _SettingTile(
                  icon: Icons.grid_view_rounded,
                  color: const Color(0xFFEC4899),
                  title: l10n.manageCategories,
                  onTap: () => openCategories(context),
                ),
                _SettingTile(
                  icon: Icons.auto_fix_high_rounded,
                  color: const Color(0xFF8B5CF6),
                  title: l10n.customizeGrid,
                  onTap: () => showCustomizeGridSheet(context),
                ),
              ],
            ),
            _Section(
              title: l10n.sectionPreferences,
              tiles: [
                _SettingTile(
                  icon: Icons.language_rounded,
                  color: const Color(0xFF3B82F6),
                  title: l10n.settingsLanguage,
                  value: languageLabel,
                  onTap: pickLanguage,
                ),
                _SettingTile(
                  icon: Icons.dark_mode_rounded,
                  color: const Color(0xFF6366F1),
                  title: l10n.settingsAppearance,
                  value: themeLabel,
                  onTap: pickTheme,
                ),
                _SettingTile(
                  icon: Icons.attach_money_rounded,
                  color: const Color(0xFF22C55E),
                  title: l10n.settingsCurrency,
                  value: 'VND',
                ),
              ],
            ),
            _Section(
              title: l10n.sectionAccountData,
              tiles: [
                _SettingTile(
                  icon: auth == null
                      ? Icons.phone_iphone_rounded
                      : Icons.cloud_done_rounded,
                  color: const Color(0xFF14B8A6),
                  title: auth == null
                      ? l10n.settingsData
                      : l10n.signedInAs(auth.currentEmail ?? ''),
                  subtitle: auth == null
                      ? l10n.dataPrototypeNote
                      : l10n.dataCloudNote,
                ),
                if (auth != null)
                  _SettingTile(
                    icon: Icons.logout_rounded,
                    color: theme.colorScheme.error,
                    title: l10n.signOut,
                    titleColor: theme.colorScheme.error,
                    onTap: auth.signOut,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom sheet listing [options]; returns the chosen key.
  static Future<T?> _pickOption<T>(
    BuildContext context,
    String title,
    Map<T, (IconData, String)> options,
    T selected,
  ) {
    return showModalBottomSheet<T>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            for (final MapEntry(:key, :value) in options.entries)
              ListTile(
                leading: Icon(value.$1),
                title: Text(value.$2),
                trailing: key == selected
                    ? Icon(
                        Icons.check_circle_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () => Navigator.of(context).pop(key),
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

/// Avatar with the initial, name (tap to edit), member-since date and
/// all-time totals.
class _ProfileCard extends ConsumerWidget {
  const _ProfileCard();

  Future<void> _editName(BuildContext context, WidgetRef ref) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _NameDialog(initial: ref.read(profileNameProvider)),
    );
    if (name != null) ref.read(profileNameProvider.notifier).state = name;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final fmt = Formatters.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final transactions = ref.watch(transactionsProvider);
    final totals = totalsOf(transactions);
    final savedName = ref.watch(profileNameProvider).trim();
    final name = savedName.isEmpty ? l10n.defaultUserName : savedName;
    // Newest first, so the last one is the earliest record.
    final since = transactions.isEmpty
        ? ref.watch(clockProvider)()
        : transactions.last.occurredAt;
    final locale = Localizations.localeOf(context).toString();

    Widget stat(String value, String label, Color? color) => Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(AppRadii.card + 8),
      ),
      child: Column(
        children: [
          Semantics(
            button: true,
            label: l10n.editName,
            excludeSemantics: true,
            child: GestureDetector(
              key: const ValueKey('edit_name'),
              onTap: () => _editName(context, ref),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          Color(0xFF7FA8F8),
                          Color(0xFF8B5CF6),
                          Color(0xFFEC4899),
                          Color(0xFF7FA8F8),
                        ],
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                      child: Text(
                        name.characters.first.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: theme.colorScheme.primary,
                      child: Icon(
                        Icons.edit_rounded,
                        size: 15,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            name,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              l10n.memberSince(DateFormat('MM/yyyy', locale).format(since)),
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(AppRadii.card),
            ),
            child: Row(
              children: [
                stat('${transactions.length}', l10n.statTransactions, null),
                stat(
                  fmt.money(totals.incomeMinor),
                  l10n.statIncome,
                  colors.income,
                ),
                stat(
                  fmt.money(totals.expenseMinor),
                  l10n.statExpense,
                  colors.expense,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Owns its text controller so it outlives the closing animation.
class _NameDialog extends StatefulWidget {
  final String initial;

  const _NameDialog({required this.initial});

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.editName),
      content: TextField(
        key: const ValueKey('profile_name'),
        controller: _controller,
        autofocus: true,
        maxLength: 40,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          hintText: l10n.defaultUserName,
          counterText: '',
        ),
        onSubmitted: (v) => Navigator.of(context).pop(v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> tiles;

  const _Section({required this.title, required this.tiles});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xs,
              bottom: AppSpacing.sm,
            ),
            child: Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < tiles.length; i++) ...[
                  if (i > 0) const Divider(height: 1, indent: 64),
                  tiles[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final String? value;
  final Color? titleColor;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.value,
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return ListTile(
      minTileHeight: 56,
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, color: titleColor),
      ),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Text(value!, style: TextStyle(color: colors.textSecondary)),
          if (onTap != null && titleColor == null)
            Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
        ],
      ),
      onTap: onTap,
    );
  }
}
