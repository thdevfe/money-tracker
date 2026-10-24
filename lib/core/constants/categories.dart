import 'package:flutter/material.dart';

class ExpenseCategory {
  final String id;
  final String label;
  final IconData icon;
  final Color color;

  const ExpenseCategory({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });
}

const List<ExpenseCategory> kExpenseCategories = [
  ExpenseCategory(
    id: 'food',
    label: 'Food & Drink',
    icon: Icons.restaurant,
    color: Color(0xFFEF6C55),
  ),
  ExpenseCategory(
    id: 'transport',
    label: 'Transport',
    icon: Icons.directions_car,
    color: Color(0xFF4C9AFF),
  ),
  ExpenseCategory(
    id: 'shopping',
    label: 'Shopping',
    icon: Icons.shopping_bag,
    color: Color(0xFFB07CE8),
  ),
  ExpenseCategory(
    id: 'bills',
    label: 'Bills & Utilities',
    icon: Icons.receipt_long,
    color: Color(0xFFF4B740),
  ),
  ExpenseCategory(
    id: 'health',
    label: 'Health',
    icon: Icons.favorite,
    color: Color(0xFFE85D75),
  ),
  ExpenseCategory(
    id: 'entertainment',
    label: 'Entertainment',
    icon: Icons.movie,
    color: Color(0xFF3DBE9C),
  ),
  ExpenseCategory(
    id: 'other',
    label: 'Other',
    icon: Icons.category,
    color: Color(0xFF8E9AAF),
  ),
];

ExpenseCategory categoryById(String id) {
  return kExpenseCategories.firstWhere(
    (c) => c.id == id,
    orElse: () => kExpenseCategories.last,
  );
}
