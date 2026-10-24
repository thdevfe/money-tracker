import '../../domain/models.dart';

const maxAmountMinor = 999999999999;

enum AmountError { required, notPositive, tooLarge }

class TransactionFormErrors {
  final AmountError? amount;
  final bool categoryMissing;
  final bool sameAccount;

  const TransactionFormErrors({
    this.amount,
    this.categoryMissing = false,
    this.sameAccount = false,
  });

  bool get isValid => amount == null && !categoryMissing && !sameAccount;
}

TransactionFormErrors validateTransactionForm({
  required TransactionType type,
  required int? amountMinor,
  required CategoryCode? category,
  required String? sourceAccountId,
  required String? destinationAccountId,
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
  );
}
