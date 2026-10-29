import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/accounts/presentation/account_detail_screen.dart';
import '../features/accounts/presentation/account_form_screen.dart';
import '../features/categories/presentation/categories_screen.dart';
import '../features/transactions/providers/transactions_provider.dart';

import '../features/transactions/domain/models.dart';
import '../features/transactions/presentation/daily_transactions_screen.dart';
import '../features/transactions/presentation/form/add_edit_transaction_screen.dart';
import '../features/transactions/presentation/form/bulk_entry_screen.dart';
import '../features/transactions/presentation/form/capture_photo_screen.dart';
import '../l10n/app_localizations.dart';

/// Result returned by the Add/Edit screen when it closes after a change.
/// [addedNext] saved and asks for another entry right away.
enum TransactionFormResult { added, addedNext, updated, deleted }

/// Opens Add Transaction. When [date] is given the form defaults to that day
/// at the current time.
/// Step 1 is the capture screen (camera, library or skip), step 2 the entry
/// screen. Without any account, the account form opens first.
Future<void> openAddTransaction(BuildContext context, {DateTime? date}) async {
  if (ProviderScope.containerOf(context).read(accountsProvider).isEmpty) {
    return openAccountForm(context);
  }
  // "Add" on the entry screen saves and starts the next one.
  while (true) {
    if (!context.mounted) return;
    final capture = await Navigator.of(context).push<CaptureResult>(
      MaterialPageRoute(
        builder: (_) => const CapturePhotoScreen(),
        fullscreenDialog: true,
      ),
    );
    if (capture == null || !context.mounted) return;
    if (capture.bulk) return _openBulkEntry(context, date);
    final result = await _openForm(
      context,
      AddEditTransactionScreen(initialDate: date, initialPhoto: capture.photo),
    );
    if (result != TransactionFormResult.addedNext) return;
  }
}

Future<void> _openBulkEntry(BuildContext context, DateTime? date) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context);
  final saved = await Navigator.of(context).push<int>(
    MaterialPageRoute(
      builder: (_) => BulkEntryScreen(initialDate: date),
      fullscreenDialog: true,
    ),
  );
  if (saved == null || saved == 0) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(l10n.bulkSaved(saved))));
}

Future<void> openEditTransaction(
  BuildContext context,
  MoneyTransaction transaction,
) async {
  await _openForm(context, AddEditTransactionScreen(existing: transaction));
}

Future<void> openDailyTransactions(BuildContext context, DateTime date) {
  return Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => DailyTransactionsScreen(date: date)),
  );
}

Future<TransactionFormResult?> _openForm(
  BuildContext context,
  Widget screen,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context);
  final result = await Navigator.of(context).push<TransactionFormResult>(
    MaterialPageRoute(builder: (_) => screen, fullscreenDialog: true),
  );
  if (result == null) return null;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(switch (result) {
          TransactionFormResult.added ||
          TransactionFormResult.addedNext => l10n.savedAdded,
          TransactionFormResult.updated => l10n.savedUpdated,
          TransactionFormResult.deleted => l10n.deleted,
        }),
      ),
    );
  return result;
}

Future<void> openAccountForm(BuildContext context, {Account? existing}) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => AccountFormScreen(existing: existing),
      fullscreenDialog: true,
    ),
  );
}

Future<void> openAccountDetail(BuildContext context, String accountId) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => AccountDetailScreen(accountId: accountId),
    ),
  );
}

Future<void> openCategories(
  BuildContext context, {
  TransactionType type = TransactionType.expense,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => CategoriesScreen(initialType: type)),
  );
}
