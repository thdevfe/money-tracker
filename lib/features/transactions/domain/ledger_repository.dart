import 'models.dart';

enum LedgerFailure {
  /// Network, server or unexpected error.
  unavailable,

  /// The account or category is referenced by transactions.
  inUse,

  /// A category with the same name and type already exists.
  duplicate,
}

/// Thrown when the backend cannot load or save data, or refuses a change.
/// Screens show a localized message for [failure] instead of [cause].
class LedgerException implements Exception {
  final LedgerFailure failure;
  final Object? cause;

  const LedgerException([this.cause, this.failure = LedgerFailure.unavailable]);

  const LedgerException.inUse() : failure = LedgerFailure.inUse, cause = null;

  const LedgerException.duplicate()
    : failure = LedgerFailure.duplicate,
      cause = null;

  @override
  String toString() => 'LedgerException(${failure.name}): $cause';
}

/// Storage boundary for accounts, custom categories and transactions.
/// Screens never talk to the backend directly, so the implementation can
/// change without UI rewrites.
abstract class LedgerRepository {
  Future<List<Account>> fetchAccounts();

  /// The user's own categories (built-in ones live in the app).
  Future<List<Category>> fetchCustomCategories();

  /// All of the user's transactions, in any order. [customCategories] lets
  /// rows resolve their custom category.
  Future<List<MoneyTransaction>> fetchTransactions(
    List<Category> customCategories,
  );

  Future<Account> createAccount(Account account);

  Future<Account> updateAccount(Account account);

  /// Fails with [LedgerFailure.inUse] while transactions reference it.
  Future<void> deleteAccount(Account account);

  /// Creates or updates a custom category. Fails with
  /// [LedgerFailure.duplicate] when the name is taken for that type.
  Future<Category> saveCategory(Category category, {required bool isNew});

  /// Fails with [LedgerFailure.inUse] while transactions reference it.
  Future<void> deleteCategory(Category category);

  /// Creates or updates [transaction] and returns the stored version.
  /// A [PickedTransactionPhoto] is uploaded first; a replaced or removed
  /// photo of [previous] is deleted only after the row is saved.
  Future<MoneyTransaction> saveTransaction(
    MoneyTransaction transaction, {
    MoneyTransaction? previous,
  });

  /// Deletes [transaction] and then its photo, if any.
  Future<void> deleteTransaction(MoneyTransaction transaction);
}
