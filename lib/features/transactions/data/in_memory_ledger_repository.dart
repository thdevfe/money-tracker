import '../domain/ledger_repository.dart';
import '../domain/ledger_rules.dart';
import '../domain/models.dart';
import 'mock_data.dart';

/// Keeps data in memory. Used for demo mode (no backend configured) and in
/// tests; applies the same rules the database enforces.
class InMemoryLedgerRepository implements LedgerRepository {
  final List<Account> _accounts;
  final List<Category> _categories;
  final Map<String, MoneyTransaction> _transactions;

  InMemoryLedgerRepository({
    List<Account> accounts = const [],
    List<Category> categories = const [],
    List<MoneyTransaction> transactions = const [],
  }) : _accounts = [...accounts],
       _categories = [...categories],
       _transactions = {for (final t in transactions) t.id: t};

  /// Sample accounts and transactions around [anchor].
  factory InMemoryLedgerRepository.demo(DateTime anchor) =>
      InMemoryLedgerRepository(
        accounts: mockAccounts,
        transactions: buildMockTransactions(anchor),
      );

  @override
  Future<List<Account>> fetchAccounts() async => [..._accounts];

  @override
  Future<List<Category>> fetchCustomCategories() async => [..._categories];

  @override
  Future<List<MoneyTransaction>> fetchTransactions(
    List<Category> customCategories,
  ) async => _transactions.values.toList();

  @override
  Future<Account> createAccount(Account account) async {
    _accounts.add(account);
    return account;
  }

  @override
  Future<Account> updateAccount(Account account) async {
    final i = _accounts.indexWhere((a) => a.id == account.id);
    _accounts[i] = account;
    return account;
  }

  @override
  Future<void> deleteAccount(Account account) async {
    if (accountInUse(account.id, _transactions.values)) {
      throw const LedgerException.inUse();
    }
    _accounts.removeWhere((a) => a.id == account.id);
  }

  @override
  Future<Category> saveCategory(
    Category category, {
    required bool isNew,
  }) async {
    final error = validateCategoryName(
      category.name ?? '',
      type: category.type,
      existing: _categories,
      editingId: isNew ? null : category.id,
    );
    if (error == NameError.duplicate) throw const LedgerException.duplicate();
    _categories
      ..removeWhere((c) => c.id == category.id)
      ..add(category);
    // Keep transactions showing the latest name, icon and color.
    for (final t in _transactions.values.toList()) {
      if (t.category?.id == category.id) {
        _transactions[t.id] = t.withCategory(category);
      }
    }
    return category;
  }

  @override
  Future<void> deleteCategory(Category category) async {
    if (categoryInUse(category.id, _transactions.values)) {
      throw const LedgerException.inUse();
    }
    _categories.removeWhere((c) => c.id == category.id);
  }

  @override
  Future<MoneyTransaction> saveTransaction(
    MoneyTransaction transaction, {
    MoneyTransaction? previous,
  }) async {
    _transactions[transaction.id] = transaction;
    return transaction;
  }

  @override
  Future<void> deleteTransaction(MoneyTransaction transaction) async {
    _transactions.remove(transaction.id);
  }
}
