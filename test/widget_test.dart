import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:expense_tracker/features/expenses/presentation/expense_list_screen.dart';
import 'package:expense_tracker/features/expenses/providers/expenses_provider.dart';

void main() {
  testWidgets('Expense list shows empty state with no expenses',
      (WidgetTester tester) async {
    late Directory tempDir;
    late Box<Map> box;

    await tester.runAsync(() async {
      tempDir = await Directory.systemTemp.createTemp('hive_test');
      Hive.init(tempDir.path);
      box = await Hive.openBox<Map>('expenses_test');
      await box.clear();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [expensesBoxProvider.overrideWithValue(box)],
        child: const MaterialApp(home: ExpenseListScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('No expenses yet'), findsOneWidget);
    expect(find.text('Expenses'), findsOneWidget);

    await tester.runAsync(() async {
      await box.close();
      await tempDir.delete(recursive: true);
    });
  });
}
