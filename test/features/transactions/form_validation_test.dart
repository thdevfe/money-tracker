import 'package:expense_tracker/core/formatting/formatters.dart';
import 'package:expense_tracker/features/transactions/domain/models.dart';
import 'package:expense_tracker/features/transactions/presentation/form/transaction_form_validation.dart';
import 'package:expense_tracker/features/transactions/presentation/form/widgets/amount_input.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('validateTransactionForm', () {
    TransactionFormErrors validate({
      TransactionType type = TransactionType.expense,
      int? amount = 1000,
      CategoryCode? category = CategoryCode.food,
      String? from = 'bank',
      String? to = 'cash',
    }) {
      return validateTransactionForm(
        type: type,
        amountMinor: amount,
        category: category,
        sourceAccountId: from,
        destinationAccountId: to,
      );
    }

    test('accepts a valid expense without a photo', () {
      expect(validate().isValid, isTrue);
    });

    test('rejects missing, zero and oversized amounts', () {
      expect(validate(amount: null).amount, AmountError.required);
      expect(validate(amount: 0).amount, AmountError.notPositive);
      expect(validate(amount: maxAmountMinor + 1).amount, AmountError.tooLarge);
    });

    test('requires a category for income and expense only', () {
      expect(validate(category: null).categoryMissing, isTrue);
      expect(
        validate(type: TransactionType.income, category: null).categoryMissing,
        isTrue,
      );
      expect(
        validate(type: TransactionType.transfer, category: null).isValid,
        isTrue,
      );
    });

    test('rejects a transfer to the same account', () {
      final errors = validate(
        type: TransactionType.transfer,
        from: 'cash',
        to: 'cash',
      );
      expect(errors.sameAccount, isTrue);
      expect(errors.isValid, isFalse);
    });
  });

  group('amount parsing and formatting', () {
    final vi = Formatters('vi', lookupAppLocalizations(const Locale('vi')));
    final en = Formatters('en', lookupAppLocalizations(const Locale('en')));

    test('parseAmountMinor reads digits only', () {
      expect(parseAmountMinor('1.250.000'), 1250000);
      expect(parseAmountMinor('1,250,000'), 1250000);
      expect(parseAmountMinor(''), isNull);
    });

    test('grouping formatter regroups digits for the locale', () {
      final formatter = AmountGroupingFormatter(vi);
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '0120000'),
      );
      expect(result.text, '120.000');
    });

    test('compact amounts are localized', () {
      expect(vi.compact(165000), '165k');
      expect(vi.compact(8000000), '8tr');
      expect(vi.compact(1200000), '1,2tr');
      expect(en.compact(1200000), '1.2M');
    });

    test('signed money never relies on color alone', () {
      expect(vi.signedMoney(TransactionType.expense, 55000), startsWith('−'));
      expect(vi.signedMoney(TransactionType.income, 55000), startsWith('+'));
      expect(vi.money(55000), contains('55.000'));
    });
  });
}
