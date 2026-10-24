import 'models.dart';

/// Validation rules for accounts and custom categories, shared by every
/// repository and by the forms.

const maxAccountNameLength = 50;
const maxCategoryNameLength = 40;

enum NameError { empty, tooLong, duplicate }

NameError? validateAccountName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return NameError.empty;
  if (trimmed.length > maxAccountNameLength) return NameError.tooLong;
  return null;
}

/// Custom category names must be unique per type, ignoring case and
/// surrounding spaces. [editingId] is the category being renamed.
NameError? validateCategoryName(
  String name, {
  required TransactionType type,
  required Iterable<Category> existing,
  String? editingId,
}) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return NameError.empty;
  if (trimmed.length > maxCategoryNameLength) return NameError.tooLong;
  final key = trimmed.toLowerCase();
  final taken = existing.any(
    (c) =>
        !c.isSystem &&
        c.type == type &&
        c.id != editingId &&
        c.name!.trim().toLowerCase() == key,
  );
  return taken ? NameError.duplicate : null;
}

bool accountInUse(String accountId, Iterable<MoneyTransaction> transactions) =>
    transactions.any(
      (t) =>
          t.accountId == accountId ||
          t.sourceAccountId == accountId ||
          t.destinationAccountId == accountId,
    );

bool categoryInUse(
  String categoryId,
  Iterable<MoneyTransaction> transactions,
) => transactions.any((t) => t.category?.id == categoryId);
