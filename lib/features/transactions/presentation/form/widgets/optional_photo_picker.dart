import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/models.dart';
import '../../widgets/transaction_thumbnail.dart';
import 'form_section.dart';

/// Optional photo: camera / library buttons, or a preview with replace and
/// remove actions. Never required for saving.
class OptionalPhotoPicker extends StatelessWidget {
  final TransactionPhoto? photo;
  final ValueChanged<ImageSource> onPick;
  final VoidCallback onRemove;

  const OptionalPhotoPicker({
    super.key,
    required this.photo,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final current = photo;
    return FormSection(
      label: l10n.photoLabel,
      helperText: current == null ? l10n.photoHelp : null,
      child: current == null
          ? Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => onPick(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: Text(l10n.photoCamera),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => onPick(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(l10n.photoLibrary),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Semantics(
                  image: true,
                  label: l10n.photoPreviewSemantics,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.card),
                    child: PhotoImage(
                      photo: current,
                      size: 112,
                      fallback: Container(
                        width: 112,
                        height: 112,
                        color: colors.elevatedSurface,
                        child: const Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => onPick(ImageSource.gallery),
                        icon: const Icon(Icons.autorenew_rounded),
                        label: Text(l10n.photoReplace),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      OutlinedButton.icon(
                        onPressed: onRemove,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                        icon: const Icon(Icons.delete_outline_rounded),
                        label: Text(l10n.photoRemove),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
