import '../../domain/models.dart';

const maxAmountMinor = 999999999999;

enum AmountError { required, notPositive, tooLarge }

class TransactionFormErrors {
  final AmountError? amount;
  final bool categoryMissing;
  final bool sameAccount;

  /// The expense or transfer-out would make the account balance negative.
  final bool insufficientBalance;

  const TransactionFormErrors({
    this.amount,
    this.categoryMissing = false,
    this.sameAccount = false,
    this.insufficientBalance = false,
  });

  bool get isValid =>
      amount == null &&
      !categoryMissing &&
      !sameAccount &&
      !insufficientBalance;
}

TransactionFormErrors validateTransactionForm({
  required TransactionType type,
  required int? amountMinor,
  required Category? category,
  required String? sourceAccountId,
  required String? destinationAccountId,

  /// Balance of the account money leaves (expense account or transfer
  /// source), not counting this transaction's previous version. Null skips
  /// the check (income).
  int? availableMinor,
}) {
  final AmountError? amount;
  if (amountMinor == null) {
    amount = AmountError.required;
  } else if (amountMinor <= 0) {
    amount = AmountError.notPositive;
  } else if (amountMinor > maxAmountMinor) {
    amount = AmountError.tooLarge;
  } else {
    amount = null;
  }
  final isTransfer = type == TransactionType.transfer;
  return TransactionFormErrors(
    amount: amount,
    categoryMissing: !isTransfer && category == null,
    sameAccount: isTransfer && sourceAccountId == destinationAccountId,
    insufficientBalance:
        amount == null &&
        availableMinor != null &&
        type != TransactionType.income &&
        amountMinor! > availableMinor,
  );
}
