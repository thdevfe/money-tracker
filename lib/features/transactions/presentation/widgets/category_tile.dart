import 'package:flutter/material.dart';

import '../../domain/models.dart';
import '../category_presentation.dart';

/// Colored rounded square with the category (or transfer) icon, shown where a
/// transaction has no photo.
class CategoryTile extends StatelessWidget {
  final MoneyTransaction transaction;
  final double size;
  final double radius;

  const CategoryTile({
    super.key,
    required this.transaction,
    required this.size,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: transaction.displayTint,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(
        transaction.displayIcon,
        size: size * 0.55,
        color: Colors.white,
      ),
    );
  }
}
