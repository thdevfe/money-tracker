import 'package:flutter/material.dart';

import '../../../../../core/formatting/formatters.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../domain/models.dart';
import '../../category_presentation.dart';

/// Bottom sheet listing accounts with balances. Returns the chosen id.
Future<String?> showAccountPicker(
  BuildContext context, {
  required String title,
  required List<Account> accounts,
  required Map<String, int> balances,
  required String? selectedId,
}) {
  final fmt = Formatters.of(context);
  return showModalBottomSheet<String>(
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
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
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
}
