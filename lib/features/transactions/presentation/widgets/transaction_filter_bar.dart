import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/transaction_query.dart';

/// All / Expense / Income / Transfer chips.
class TransactionFilterBar extends StatelessWidget {
  final TypeFilter selected;
  final ValueChanged<TypeFilter> onChanged;

  const TransactionFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String label(TypeFilter f) => switch (f) {
      TypeFilter.all => l10n.filterAll,
      TypeFilter.expense => l10n.typeExpense,
      TypeFilter.income => l10n.typeIncome,
      TypeFilter.transfer => l10n.typeTransfer,
    };
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          for (final f in TypeFilter.values)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: ChoiceChip(
                label: Text(label(f)),
                selected: f == selected,
                onSelected: (_) => onChanged(f),
              ),
            ),
        ],
      ),
    );
  }
}
