import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/ledger.dart';

/// "Select day" sheet: a month calendar with a Today shortcut. Returns the
/// chosen day (no time), or null when dismissed.
Future<DateTime?> showDayPicker(
  BuildContext context, {
  required DateTime initial,
  required DateTime today,
}) {
  final l10n = AppLocalizations.of(context);
  return showModalBottomSheet<DateTime>(
    context: context,
    showDragHandle: true,
    // The month grid is taller than the default half-height sheet.
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.tonal(
                    // The theme makes filled buttons full width.
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 40),
                    ),
                    onPressed: () => Navigator.of(context).pop(today),
                    child: Text(l10n.today),
                  ),
                ),
                Text(
                  l10n.chooseDay,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          CalendarDatePicker(
            initialDate: dateOnly(initial),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            currentDate: today,
            onDateChanged: (d) => Navigator.of(context).pop(d),
          ),
        ],
      ),
    ),
  );
}
