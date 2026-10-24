import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/formatting/formatters.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../l10n/app_localizations.dart';

/// Parses the digits of a formatted amount ("1.250.000") into minor units.
/// Returns null when there are no digits.
int? parseAmountMinor(String text) {
  final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return null;
  return int.tryParse(digits);
}

/// Keeps only digits and regroups them for the current locale while typing.
class AmountGroupingFormatter extends TextInputFormatter {
  static const maxDigits = 13;

  final Formatters fmt;

  AmountGroupingFormatter(this.fmt);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > maxDigits) return oldValue;
    digits = digits.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    final text = digits.isEmpty ? '' : fmt.groupDigits(int.parse(digits));
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Large amount field with a numeric keyboard and live digit grouping.
class AmountInput extends StatelessWidget {
  final TextEditingController controller;
  final Color color;
  final String? errorText;
  final bool autofocus;
  final ValueChanged<String>? onChanged;

  const AmountInput({
    super.key,
    required this.controller,
    required this.color,
    this.errorText,
    this.autofocus = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    return TextField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      inputFormatters: [AmountGroupingFormatter(Formatters.of(context))],
      onChanged: onChanged,
      textAlign: TextAlign.center,
      style: theme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      decoration: InputDecoration(
        labelText: l10n.amountLabel,
        floatingLabelAlignment: FloatingLabelAlignment.center,
        hintText: '0',
        hintStyle: theme.textTheme.headlineMedium?.copyWith(
          color: colors.textSecondary.withValues(alpha: 0.5),
        ),
        suffixText: '₫',
        suffixStyle: theme.textTheme.titleLarge?.copyWith(
          color: colors.textSecondary,
        ),
        errorText: errorText,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
      ),
    );
  }
}
