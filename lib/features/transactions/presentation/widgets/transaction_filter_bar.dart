import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/transactions_provider.dart';

/// All / Expense / Income / Transfer chips.
class TransactionFilterBar extends StatelessWidget {
  final TransactionFilter selected;
  final ValueChanged<TransactionFilter> onChanged;

  const TransactionFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String label(TransactionFilter f) => switch (f) {
      TransactionFilter.all => l10n.filterAll,
      TransactionFilter.expense => l10n.typeExpense,
      TransactionFilter.income => l10n.typeIncome,
      TransactionFilter.transfer => l10n.typeTransfer,
    };
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          for (final f in TransactionFilter.values)
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
