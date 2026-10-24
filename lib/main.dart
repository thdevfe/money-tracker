import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/hive_service.dart';
import 'core/theme/app_theme.dart';
import 'features/expenses/presentation/expense_list_screen.dart';
import 'features/expenses/providers/expenses_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final expensesBox = await HiveService.openExpensesBox();

  runApp(
    ProviderScope(
      overrides: [
        expensesBoxProvider.overrideWithValue(expensesBox),
      ],
      child: const ExpenseTrackerApp(),
    ),
  );
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const ExpenseListScreen(),
    );
  }
}
