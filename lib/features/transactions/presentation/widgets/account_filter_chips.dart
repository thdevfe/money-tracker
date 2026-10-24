import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/transactions_provider.dart';
import '../category_presentation.dart';

/// Horizontal "All / account…" chips. `null` means all accounts.
class AccountFilterChips extends ConsumerWidget {
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  const AccountFilterChips({
    super.key,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final accounts = ref.watch(accountsProvider);

    Widget chip(String? id, IconData icon, String label) => Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: ChoiceChip(
        avatar: Icon(icon, size: 16),
        label: Text(label),
        selected: selectedId == id,
        onSelected: (_) => onChanged(id),
      ),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          chip(null, Icons.layers_rounded, l10n.filterAll),
          for (final a in accounts) chip(a.id, a.type.icon, a.name),
        ],
      ),
    );
  }
}
