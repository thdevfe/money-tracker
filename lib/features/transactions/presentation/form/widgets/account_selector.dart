import 'package:flutter/material.dart';

import '../../../../../core/formatting/formatters.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../domain/models.dart';
import '../../category_presentation.dart';

/// Tappable field that picks an account from a bottom sheet.
class AccountSelector extends StatelessWidget {
  final String label;
  final List<Account> accounts;
  final Map<String, int> balances;
  final String? selectedId;
  final ValueChanged<String> onChanged;
  final String? errorText;

  const AccountSelector({
    super.key,
    required this.label,
    required this.accounts,
    required this.balances,
    required this.selectedId,
    required this.onChanged,
    this.errorText,
  });

  Future<void> _pick(BuildContext context) async {
    final fmt = Formatters.of(context);
    final id = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.sm,
              ),
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final a in accounts)
              ListTile(
                leading: Icon(a.type.icon),
                title: Text(a.name),
                subtitle: Text(fmt.money(balances[a.id] ?? 0)),
                trailing: a.id == selectedId
                    ? Icon(
                        Icons.check_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () => Navigator.of(context).pop(a.id),
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
    if (id != null) onChanged(id);
  }

  @override
  Widget build(BuildContext context) {
    Account? selected;
    for (final a in accounts) {
      if (a.id == selectedId) selected = a;
    }
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.input),
      onTap: () => _pick(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          prefixIcon: Icon(selected?.type.icon ?? Icons.account_balance_wallet),
          suffixIcon: const Icon(Icons.expand_more_rounded),
        ),
        child: Text(selected?.name ?? '', maxLines: 1),
      ),
    );
  }
}
