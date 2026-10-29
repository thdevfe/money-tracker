import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';

/// Rounded "icon label ⌄" chip that opens a picker.
class PickerChip extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String label;
  final VoidCallback onTap;

  const PickerChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    return Material(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
      shape: StadiumBorder(
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.35),
        ),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 20,
                  color: iconColor ?? theme.colorScheme.onSurface,
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(
                Icons.expand_more_rounded,
                size: 20,
                color: colors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
