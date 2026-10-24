import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';

/// Label + content + optional error, used for form groups that are not plain
/// text fields.
class FormSection extends StatelessWidget {
  final String label;
  final String? helperText;
  final String? errorText;
  final Widget child;

  const FormSection({
    super.key,
    required this.label,
    required this.child,
    this.helperText,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (helperText != null)
          Text(
            helperText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        child,
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              errorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
