import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/models.dart';
import '../../category_presentation.dart';
import 'form_section.dart';

/// Icon chips for the categories of one transaction type.
class CategorySelector extends StatelessWidget {
  final TransactionType type;
  final CategoryCode? selected;
  final ValueChanged<CategoryCode> onChanged;
  final String? errorText;

  const CategorySelector({
    super.key,
    required this.type,
    required this.selected,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return FormSection(
      label: l10n.categoryLabel,
      errorText: errorText,
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final c in CategoryCode.forType(type))
            ChoiceChip(
              avatar: Icon(
                c.icon,
                size: 18,
                color: c == selected
                    ? scheme.onPrimaryContainer
                    : scheme.onSurfaceVariant,
              ),
              label: Text(c.label(l10n)),
              selected: c == selected,
              onSelected: (_) => onChanged(c),
            ),
        ],
      ),
    );
  }
}
