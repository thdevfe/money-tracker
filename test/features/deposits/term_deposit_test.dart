import 'package:expense_tracker/features/deposits/data/in_memory_deposit_repository.dart';
import 'package:expense_tracker/features/deposits/domain/term_deposit.dart';
import 'package:expense_tracker/features/deposits/providers/deposits_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

TermDeposit deposit({
  DateTime? start,
  int months = 6,
  int principal = 100000000,
  int rateBp = 500,
}) => TermDeposit(
  id: 'd1',
  bankName: 'Vietcombank',
  principalMinor: principal,
  rateBasisPoints: rateBp,
  startDate: start ?? DateTime(2026, 1, 15),
  termMonths: months,
);

void main() {
  test('maturity keeps the day, clamped to the month end', () {
    expect(deposit().maturityDate, DateTime(2026, 7, 15));
    expect(
      deposit(start: DateTime(2026, 1, 31), months: 1).maturityDate,
      DateTime(2026, 2, 28),
    );
    expect(
      deposit(start: DateTime(2026, 11, 10), months: 3).maturityDate,
      DateTime(2027, 2, 10),
    );
  });

  test('simple interest over the term on a 365-day year', () {
    // 100tr at 5%/year for 181 days.
    final d = deposit();
    expect(d.termDays, 181);
    expect(d.interestAtMaturityMinor, (100000000 * 0.05 * 181 / 365).round());
  });

  test('accrued interest and progress follow the days elapsed', () {
    final d = deposit();
    expect(d.accruedInterestMinor(DateTime(2026, 1, 1)), 0);
    expect(d.progress(DateTime(2026, 1, 1)), 0);
    expect(
      d.accruedInterestMinor(DateTime(2026, 2, 14)),
      (100000000 * 0.05 * 30 / 365).round(),
    );
    expect(d.isMatured(DateTime(2026, 7, 14)), isFalse);
    expect(d.isMatured(DateTime(2026, 7, 15)), isTrue);
    expect(
      d.accruedInterestMinor(DateTime(2027, 1, 1)),
      d.interestAtMaturityMinor,
    );
    expect(d.progress(DateTime(2027, 1, 1)), 1);
  });

  test('the notifier saves, updates and deletes', () async {
    final container = ProviderContainer(
      overrides: [
        depositRepositoryProvider.overrideWithValue(
          InMemoryDepositRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    final notifier = container.read(depositsProvider.notifier);
    await notifier.load();

    await notifier.save(deposit());
    expect(container.read(depositsProvider).value, hasLength(1));
    await notifier.save(deposit(principal: 5000000));
    expect(
      container.read(depositsProvider).value!.single.principalMinor,
      5000000,
    );
    await notifier.delete(deposit());
    expect(container.read(depositsProvider).value, isEmpty);
  });
}
