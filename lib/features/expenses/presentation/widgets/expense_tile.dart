import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/categories.dart';
import '../../data/expense_model.dart';

class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback onTap;

  const ExpenseTile({super.key, required this.expense, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final category = categoryById(expense.categoryId);
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat.MMMd();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _Thumbnail(imagePath: expense.imagePath, category: category),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${category.label} · ${dateFormat.format(expense.date)}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                currencyFormat.format(expense.amount),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final String? imagePath;
  final ExpenseCategory category;

  const _Thumbnail({required this.imagePath, required this.category});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    if (imagePath != null && File(imagePath!).existsSync()) {
      return ClipRRect(
        borderRadius: radius,
        child: Image.file(
          File(imagePath!),
          width: 48,
          height: 48,
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.15),
        borderRadius: radius,
      ),
      child: Icon(category.icon, color: category.color),
    );
  }
}
