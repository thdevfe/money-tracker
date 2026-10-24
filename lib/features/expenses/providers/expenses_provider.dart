import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../data/expense_model.dart';
import '../data/image_storage_service.dart';

final expensesBoxProvider = Provider<Box<Map>>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

final imageStorageServiceProvider = Provider<ImageStorageService>((ref) {
  return ImageStorageService();
});

class ExpensesNotifier extends StateNotifier<List<Expense>> {
  final Box<Map> _box;
  final ImageStorageService _imageStorage;

  ExpensesNotifier(this._box, this._imageStorage) : super([]) {
    _load();
  }

  void _load() {
    final expenses = _box.values
        .map((m) => Expense.fromMap(Map<String, dynamic>.from(m)))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    state = expenses;
  }

  Future<void> addExpense(Expense expense) async {
    await _box.put(expense.id, expense.toMap());
    _load();
  }

  Future<void> updateExpense(Expense expense) async {
    await _box.put(expense.id, expense.toMap());
    _load();
  }

  Future<void> deleteExpense(String id) async {
    final matches = state.where((e) => e.id == id);
    if (matches.isNotEmpty && matches.first.imagePath != null) {
      await _imageStorage.deleteImage(matches.first.imagePath);
    }
    await _box.delete(id);
    _load();
  }
}

final expensesProvider =
    StateNotifierProvider<ExpensesNotifier, List<Expense>>((ref) {
  final box = ref.watch(expensesBoxProvider);
  final imageStorage = ref.watch(imageStorageServiceProvider);
  return ExpensesNotifier(box, imageStorage);
});

final expenseSearchQueryProvider = StateProvider<String>((ref) => '');
final expenseCategoryFilterProvider = StateProvider<String?>((ref) => null);

final filteredExpensesProvider = Provider<List<Expense>>((ref) {
  final expenses = ref.watch(expensesProvider);
  final query = ref.watch(expenseSearchQueryProvider).trim().toLowerCase();
  final category = ref.watch(expenseCategoryFilterProvider);

  return expenses.where((e) {
    final matchesQuery = query.isEmpty ||
        e.title.toLowerCase().contains(query) ||
        e.note.toLowerCase().contains(query);
    final matchesCategory = category == null || e.categoryId == category;
    return matchesQuery && matchesCategory;
  }).toList();
});
