import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../domain/models.dart';
import '../../category_presentation.dart';

class TransactionTypeSelector extends StatelessWidget {
  final TransactionType selected;
  final ValueChanged<TransactionType>? onChanged;

  const TransactionTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    // Keep the selected type visible when the selector is disabled (editing).
    return SegmentedButton<TransactionType>(
      showSelectedIcon: false,
      style: ButtonStyle(
        visualDensity: VisualDensity.standard,
        minimumSize: const WidgetStatePropertyAll(Size(0, 44)),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primaryContainer
              : null,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.onPrimaryContainer
              : states.contains(WidgetState.disabled)
              ? scheme.onSurfaceVariant.withValues(alpha: 0.6)
              : scheme.onSurface,
        ),
      ),
      segments: [
        for (final type in TransactionType.values)
          ButtonSegment(
            value: type,
            label: Text(
              type.label(l10n),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      selected: {selected},
      onSelectionChanged: onChanged == null
          ? null
          : (values) => onChanged!(values.first),
    );
  }
}
