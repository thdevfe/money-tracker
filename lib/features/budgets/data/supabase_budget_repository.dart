import 'package:supabase_flutter/supabase_flutter.dart';

import '../../transactions/domain/ledger_repository.dart';
import '../domain/budget.dart';

/// [BudgetRepository] on the `budgets` table; see
/// `supabase/migrations/0004_budgets.sql`.
class SupabaseBudgetRepository implements BudgetRepository {
  final SupabaseClient _client;

  SupabaseBudgetRepository(this._client);

  @override
  Future<List<Budget>> fetchBudgets() => _guard(() async {
    final rows = await _client.from('budgets').select().order('created_at');
    return rows.map(_fromRow).toList();
  });

  @override
  Future<Budget> saveBudget(Budget budget, {required bool isNew}) =>
      _guard(() async {
        final table = _client.from('budgets');
        final row = isNew
            ? await table.insert(_toRow(budget)).select().single()
            : await table
                  .update(_toRow(budget))
                  .eq('id', budget.id)
                  .select()
                  .single();
        return _fromRow(row);
      });

  @override
  Future<void> deleteBudget(Budget budget) =>
      _guard(() => _client.from('budgets').delete().eq('id', budget.id));

  static Map<String, dynamic> _toRow(Budget b) => {
    'id': b.id,
    'name': b.name,
    'limit_minor': b.limitMinor,
    'category_ids': b.categoryIds,
  };

  static Budget _fromRow(Map<String, dynamic> r) => Budget(
    id: r['id'] as String,
    name: r['name'] as String,
    limitMinor: (r['limit_minor'] as num).toInt(),
    categoryIds: [
      for (final id in (r['category_ids'] as List? ?? const [])) id as String,
    ],
  );

  static Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e) {
      throw LedgerException(e);
    }
  }
}
