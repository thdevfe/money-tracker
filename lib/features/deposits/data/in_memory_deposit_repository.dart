import '../domain/term_deposit.dart';

class InMemoryDepositRepository implements DepositRepository {
  final Map<String, TermDeposit> _deposits;

  InMemoryDepositRepository([List<TermDeposit> deposits = const []])
    : _deposits = {for (final d in deposits) d.id: d};

  @override
  Future<List<TermDeposit>> fetchDeposits() async => _deposits.values.toList();

  @override
  Future<TermDeposit> saveDeposit(
    TermDeposit deposit, {
    required bool isNew,
  }) async => _deposits[deposit.id] = deposit;

  @override
  Future<void> deleteDeposit(TermDeposit deposit) async =>
      _deposits.remove(deposit.id);
}
