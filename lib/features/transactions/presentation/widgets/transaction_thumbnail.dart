import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/models.dart';
import '../category_presentation.dart';

/// Rounded photo thumbnail, or the category icon when there is no photo or
/// the image cannot be loaded.
class TransactionThumbnail extends StatelessWidget {
  final MoneyTransaction transaction;
  final double size;
  final double radius;

  const TransactionThumbnail({
    super.key,
    required this.transaction,
    this.size = 44,
    this.radius = AppRadii.listThumbnail,
  });

  @override
  Widget build(BuildContext context) {
    final photo = transaction.photo;
    final fallback = _IconTile(transaction: transaction, size: size);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: photo == null
          ? fallback
          : PhotoImage(photo: photo, size: size, fallback: fallback),
    );
  }
}

/// A square, cover-cropped photo decoded at display size.
class PhotoImage extends StatelessWidget {
  final TransactionPhoto photo;
  final double size;
  final Widget fallback;

  const PhotoImage({
    super.key,
    required this.photo,
    required this.size,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final cacheSize = (size * MediaQuery.devicePixelRatioOf(context)).ceil();
    return Image(
      image: ResizeImage.resizeIfNeeded(cacheSize, null, photo.imageProvider),
      width: size,
      height: size,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}

class _IconTile extends StatelessWidget {
  final MoneyTransaction transaction;
  final double size;

  const _IconTile({required this.transaction, required this.size});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = AppColors.of(context);
    final (background, foreground) = switch (transaction.type) {
      TransactionType.expense => (
        colors.elevatedSurface,
        scheme.onSurfaceVariant,
      ),
      TransactionType.income => (scheme.primaryContainer, colors.income),
      TransactionType.transfer => (
        colors.transfer.withValues(alpha: 0.14),
        colors.transfer,
      ),
    };
    return Container(
      width: size,
      height: size,
      color: background,
      child: Icon(transaction.displayIcon, size: size * 0.5, color: foreground),
    );
  }
}
