import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/accounts/presentation/account_detail_screen.dart';
import '../features/accounts/presentation/account_form_screen.dart';
import '../features/categories/presentation/categories_screen.dart';
import '../features/transactions/providers/transactions_provider.dart';

import '../features/transactions/domain/models.dart';
import '../features/transactions/presentation/daily_transactions_screen.dart';
import '../features/transactions/presentation/form/add_edit_transaction_screen.dart';
import '../features/transactions/presentation/form/capture_photo_screen.dart';
import '../l10n/app_localizations.dart';

/// Result returned by the Add/Edit screen when it closes after a change.
enum TransactionFormResult { added, updated, deleted }

/// Opens Add Transaction. When [date] is given the form defaults to that day
/// at the current time.
/// Step 1 is the capture screen (camera, library or skip), step 2 the entry
/// screen. Without any account, the account form opens first.
Future<void> openAddTransaction(BuildContext context, {DateTime? date}) async {
  if (ProviderScope.containerOf(context).read(accountsProvider).isEmpty) {
    return openAccountForm(context);
  }
  final capture = await Navigator.of(context).push<CaptureResult>(
    MaterialPageRoute(
      builder: (_) => const CapturePhotoScreen(),
      fullscreenDialog: true,
    ),
  );
  if (capture == null || !context.mounted) return;
  await _openForm(
    context,
    AddEditTransactionScreen(initialDate: date, initialPhoto: capture.photo),
  );
}

Future<void> openEditTransaction(
  BuildContext context,
  MoneyTransaction transaction,
) {
  return _openForm(context, AddEditTransactionScreen(existing: transaction));
}

Future<void> openDailyTransactions(BuildContext context, DateTime date) {
  return Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => DailyTransactionsScreen(date: date)),
  );
}

Future<void> _openForm(BuildContext context, Widget screen) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context);
  final result = await Navigator.of(context).push<TransactionFormResult>(
    MaterialPageRoute(builder: (_) => screen, fullscreenDialog: true),
  );
  if (result == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(switch (result) {
          TransactionFormResult.added => l10n.savedAdded,
          TransactionFormResult.updated => l10n.savedUpdated,
          TransactionFormResult.deleted => l10n.deleted,
        }),
      ),
    );
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
