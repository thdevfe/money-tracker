import 'package:expense_tracker/core/formatting/formatters.dart';
import 'package:expense_tracker/features/transactions/domain/models.dart';
import 'package:expense_tracker/features/transactions/presentation/form/transaction_form_validation.dart';
import 'package:expense_tracker/features/transactions/presentation/form/keypad_expression.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('validateTransactionForm', () {
    TransactionFormErrors validate({
      TransactionType type = TransactionType.expense,
      int? amount = 1000,
      Category? category = const Category.system(CategoryCode.food),
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

    test('blocks spending more than the account holds', () {
      TransactionFormErrors check(TransactionType type, int available) =>
          validateTransactionForm(
            type: type,
            amountMinor: 50000,
            category: Category.system(
              type == TransactionType.income
                  ? CategoryCode.salary
                  : CategoryCode.food,
            ),
            sourceAccountId: 'bank',
            destinationAccountId: 'cash',
            availableMinor: available,
          );
      expect(check(TransactionType.expense, 40000).insufficientBalance, isTrue);
      expect(check(TransactionType.expense, 50000).isValid, isTrue);
      expect(check(TransactionType.transfer, 0).insufficientBalance, isTrue);
      // Income never needs available money.
      expect(check(TransactionType.income, 0).isValid, isTrue);
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

    KeypadExpression type(String keys) {
      var e = const KeypadExpression.empty();
      for (final k in keys.split(' ')) {
        e = switch (k) {
          '+' => e.appendOp(KeypadOp.add),
          '-' => e.appendOp(KeypadOp.subtract),
          '*' => e.appendOp(KeypadOp.multiply),
          '/' => e.appendOp(KeypadOp.divide),
          '<' => e.backspace(),
          _ => e.appendDigits(k),
        };
      }
      return e;
    }

    test('keypad builds numbers, including the 000 key', () {
      expect(type('1 2 000').evaluate(), 12000);
      expect(type('000 5').evaluate(), 5);
      expect(type('1 2 <').evaluate(), 1);
      expect(const KeypadExpression.empty().evaluate(), isNull);
    });

    test('keypad evaluates with operator precedence', () {
      expect(type('120 000 + 35 000').evaluate(), 155000);
      expect(type('100 - 20 * 3').evaluate(), 40);
      expect(type('100 / 3').evaluate(), 33);
      expect(type('100 / 0').evaluate(), isNull);
      // A trailing operator is ignored; a repeated one replaces it.
      expect(type('50 + * 2').evaluate(), 100);
      expect(type('50 +').evaluate(), 50);
    });

    test('keypad formats with locale grouping', () {
      expect(type('1200 000 + 5').format(vi.groupDigits), '1.200.000 + 5');
      expect(type('9 / 2').format(vi.groupDigits), '9 ÷ 2');
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
