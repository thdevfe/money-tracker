import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/in_memory_deposit_repository.dart';
import '../domain/term_deposit.dart';

/// In memory by default (demo mode, tests); `main.dart` overrides it with
/// Supabase when a backend is configured.
final depositRepositoryProvider = Provider<DepositRepository>(
  (ref) => InMemoryDepositRepository(),
);

/// The user's term deposits, earliest start first. Changes are saved before
/// the list updates.
class DepositsNotifier extends StateNotifier<AsyncValue<List<TermDeposit>>> {
  final DepositRepository _repository;

  DepositsNotifier(this._repository) : super(const AsyncLoading()) {
    load();
  }

  static List<TermDeposit> _sorted(Iterable<TermDeposit> items) =>
      items.toList()..sort((a, b) => a.startDate.compareTo(b.startDate));

  Future<void> load() async {
    state = const AsyncLoading();
    try {
      final deposits = await _repository.fetchDeposits();
      if (mounted) state = AsyncData(_sorted(deposits));
    } catch (e, stack) {
      if (mounted) state = AsyncError(e, stack);
    }
  }

  List<TermDeposit> get _current => state.valueOrNull ?? const [];

  Future<void> save(TermDeposit deposit) async {
    final isNew = !_current.any((d) => d.id == deposit.id);
    final saved = await _repository.saveDeposit(deposit, isNew: isNew);
    if (!mounted) return;
    state = AsyncData(
      _sorted([
        for (final d in _current)
          if (d.id != saved.id) d,
        saved,
      ]),
    );
  }

  Future<void> delete(TermDeposit deposit) async {
    await _repository.deleteDeposit(deposit);
    if (!mounted) return;
    state = AsyncData([
      for (final d in _current)
        if (d.id != deposit.id) d,
    ]);
  }
}

final depositsProvider =
    StateNotifierProvider<DepositsNotifier, AsyncValue<List<TermDeposit>>>(
      (ref) => DepositsNotifier(ref.watch(depositRepositoryProvider)),
    );
