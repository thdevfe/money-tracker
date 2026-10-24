import 'package:expense_tracker/features/transactions/data/in_memory_ledger_repository.dart';
import 'package:expense_tracker/features/transactions/domain/ledger_repository.dart';
import 'package:expense_tracker/features/transactions/domain/ledger_rules.dart';
import 'package:expense_tracker/features/transactions/domain/models.dart';
import 'package:expense_tracker/features/transactions/providers/transactions_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const cash = Account(id: 'cash', name: 'Cash', type: AccountType.cash);
const bank = Account(id: 'bank', name: 'Bank', type: AccountType.bank);

Category custom(String id, String name, {TransactionType? type}) =>
    Category.custom(
      id: id,
      type: type ?? TransactionType.expense,
      name: name,
      iconKey: 'coffee',
      colorKey: 'orange',
    );

MoneyTransaction expense(String id, {Category? category, String? account}) =>
    MoneyTransaction(
      id: id,
      type: TransactionType.expense,
      amountMinor: 1000,
      occurredAt: DateTime(2026, 10, 1),
      accountId: account ?? 'cash',
      category: category ?? const Category.system(CategoryCode.food),
    );

Future<ProviderContainer> containerWith(InMemoryLedgerRepository repo) async {
  final container = ProviderContainer(
    overrides: [ledgerRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(container.dispose);
  container.read(ledgerProvider);
  await Future<void>.delayed(Duration.zero);
  return container;
}

void main() {
  group('names', () {
    test('account names are trimmed and limited', () {
      expect(validateAccountName('  '), NameError.empty);
      expect(validateAccountName('a' * 51), NameError.tooLong);
      expect(validateAccountName(' Ví '), isNull);
    });

    test('custom category names are unique per type, ignoring case', () {
      final existing = [custom('1', 'Cà phê')];
      expect(
        validateCategoryName(
          ' cà PHÊ ',
          type: TransactionType.expense,
          existing: existing,
        ),
        NameError.duplicate,
      );
      // Same name is fine for the other type, or when renaming itself.
      expect(
        validateCategoryName(
          'Cà phê',
          type: TransactionType.income,
          existing: existing,
        ),
        isNull,
      );
      expect(
        validateCategoryName(
          'Cà phê',
          type: TransactionType.expense,
          existing: existing,
          editingId: '1',
        ),
        isNull,
      );
    });
  });

  group('ledger notifier', () {
    test('an account with transactions cannot be deleted', () async {
      final c = await containerWith(
        InMemoryLedgerRepository(
          accounts: [cash, bank],
          transactions: [expense('t1')],
        ),
      );
      final notifier = c.read(ledgerProvider.notifier);

      await expectLater(
        notifier.deleteAccount(cash),
        throwsA(
          isA<LedgerException>().having(
            (e) => e.failure,
            'failure',
            LedgerFailure.inUse,
          ),
        ),
      );
      await notifier.deleteAccount(bank);
      expect(c.read(accountsProvider).map((a) => a.id), ['cash']);
    });

    test('opening balance is locked once the account is used', () async {
      final c = await containerWith(
        InMemoryLedgerRepository(
          accounts: [cash, bank],
          transactions: [expense('t1')],
        ),
      );
      final notifier = c.read(ledgerProvider.notifier);

      await expectLater(
        notifier.updateAccount(
          const Account(
            id: 'cash',
            name: 'Cash',
            type: AccountType.cash,
            openingBalanceMinor: 5000,
          ),
        ),
        throwsA(isA<LedgerException>()),
      );
      // Renaming is fine; an unused account can change its opening balance.
      await notifier.updateAccount(
        const Account(id: 'cash', name: 'Ví', type: AccountType.cash),
      );
      await notifier.updateAccount(
        const Account(
          id: 'bank',
          name: 'Bank',
          type: AccountType.bank,
          openingBalanceMinor: 900000,
        ),
      );
      expect(c.read(accountByIdProvider)['cash']!.name, 'Ví');
      expect(c.read(accountByIdProvider)['bank']!.openingBalanceMinor, 900000);
    });

    test('used categories are archived instead of deleted', () async {
      final coffee = custom('c1', 'Cà phê');
      final c = await containerWith(
        InMemoryLedgerRepository(
          accounts: [cash],
          categories: [coffee],
          transactions: [expense('t1', category: coffee)],
        ),
      );
      final notifier = c.read(ledgerProvider.notifier);

      await expectLater(
        notifier.deleteCategory(coffee),
        throwsA(isA<LedgerException>()),
      );
      await notifier.saveCategory(coffee.copyWith(isArchived: true));

      final pickable = c.read(
        selectableCategoriesProvider(TransactionType.expense),
      );
      expect(pickable.any((cat) => cat.id == 'c1'), isFalse);
      // The old transaction still shows its category.
      expect(c.read(transactionsProvider).single.category?.name, 'Cà phê');
    });

    test('renaming a category updates its transactions', () async {
      final coffee = custom('c1', 'Cà phê');
      final c = await containerWith(
        InMemoryLedgerRepository(
          accounts: [cash],
          categories: [coffee],
          transactions: [expense('t1', category: coffee)],
        ),
      );
      await c
          .read(ledgerProvider.notifier)
          .saveCategory(coffee.copyWith(name: 'Coffee'));
      expect(c.read(transactionsProvider).single.category?.name, 'Coffee');
    });

    test('duplicate custom category names are refused', () async {
      final c = await containerWith(
        InMemoryLedgerRepository(
          accounts: [cash],
          categories: [custom('c1', 'Cà phê')],
        ),
      );
      await expectLater(
        c.read(ledgerProvider.notifier).saveCategory(custom('c2', 'cà phê')),
        throwsA(
          isA<LedgerException>().having(
            (e) => e.failure,
            'failure',
            LedgerFailure.duplicate,
          ),
        ),
      );
    });
  });
}
