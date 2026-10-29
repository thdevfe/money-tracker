import 'package:supabase_flutter/supabase_flutter.dart';

import '../../transactions/domain/ledger_repository.dart';
import '../domain/term_deposit.dart';

/// [DepositRepository] on the `term_deposits` table; see
/// `supabase/migrations/0003_term_deposits.sql`. Errors surface as
/// [LedgerException] like the rest of the data layer.
class SupabaseDepositRepository implements DepositRepository {
  final SupabaseClient _client;

  SupabaseDepositRepository(this._client);

  @override
  Future<List<TermDeposit>> fetchDeposits() => _guard(() async {
    final rows = await _client
        .from('term_deposits')
        .select()
        .order('start_date');
    return rows.map(_fromRow).toList();
  });

  @override
  Future<TermDeposit> saveDeposit(TermDeposit deposit, {required bool isNew}) =>
      _guard(() async {
        final table = _client.from('term_deposits');
        final row = isNew
            ? await table.insert(_toRow(deposit)).select().single()
            : await table
                  .update(_toRow(deposit))
                  .eq('id', deposit.id)
                  .select()
                  .single();
        return _fromRow(row);
      });

  @override
  Future<void> deleteDeposit(TermDeposit deposit) =>
      _guard(() => _client.from('term_deposits').delete().eq('id', deposit.id));

  static Map<String, dynamic> _toRow(TermDeposit d) => {
    'id': d.id,
    'bank_name': d.bankName,
    'principal_minor': d.principalMinor,
    'rate_bp': d.rateBasisPoints,
    'start_date': _date(d.startDate),
    'term_months': d.termMonths,
  };

  static TermDeposit _fromRow(Map<String, dynamic> r) => TermDeposit(
    id: r['id'] as String,
    bankName: r['bank_name'] as String,
    principalMinor: (r['principal_minor'] as num).toInt(),
    rateBasisPoints: (r['rate_bp'] as num).toInt(),
    startDate: DateTime.parse(r['start_date'] as String),
    termMonths: (r['term_months'] as num).toInt(),
  );

  static String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e) {
      throw LedgerException(e);
    }
  }
}
