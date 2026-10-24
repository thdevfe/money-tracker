import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/ledger_repository.dart';
import '../domain/models.dart';

/// [LedgerRepository] backed by Supabase (Postgres + Storage). Row-level
/// security limits every query to the signed-in user's rows; see
/// `supabase/migrations/0001_init.sql`.
class SupabaseLedgerRepository implements LedgerRepository {
  static const _photoBucket = 'transaction-photos';

  /// Signed photo URLs stay valid for a day; data reloads refresh them.
  static const _signedUrlSeconds = 60 * 60 * 24;

  final SupabaseClient _client;

  /// Custom categories by id, for resolving transaction rows.
  Map<String, Category> _customCategories = const {};

  SupabaseLedgerRepository(this._client);

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw const LedgerException('Not signed in');
    return id;
  }

  StorageFileApi get _photos => _client.storage.from(_photoBucket);

  @override
  Future<List<Account>> fetchAccounts() => _guard(() async {
    final rows = await _client.from('accounts').select().order('created_at');
    return rows.map(_accountFromRow).toList();
  });

  @override
  Future<List<Category>> fetchCustomCategories() => _guard(() async {
    final rows = await _client.from('categories').select().order('created_at');
    return rows.map(_categoryFromRow).toList();
  });

  @override
  Future<List<MoneyTransaction>> fetchTransactions(
    List<Category> customCategories,
  ) => _guard(() async {
    _customCategories = {for (final c in customCategories) c.id: c};
    final rows = await _client
        .from('transactions')
        .select()
        .order('occurred_at', ascending: false);
    final paths = [
      for (final r in rows)
        if (r['photo_path'] case final String path) path,
    ];
    final urls = await _signedUrls(paths);
    return rows.map((r) => _transactionFromRow(r, urls)).toList();
  });

  @override
  Future<Account> createAccount(Account account) => _guard(() async {
    final row = await _client
        .from('accounts')
        .insert(_rowFromAccount(account))
        .select()
        .single();
    return _accountFromRow(row);
  });

  @override
  Future<Account> updateAccount(Account account) => _guard(() async {
    final row = await _client
        .from('accounts')
        .update(_rowFromAccount(account))
        .eq('id', account.id)
        .select()
        .single();
    return _accountFromRow(row);
  });

  @override
  Future<void> deleteAccount(Account account) =>
      _guard(() => _client.from('accounts').delete().eq('id', account.id));

  @override
  Future<Category> saveCategory(Category category, {required bool isNew}) =>
      _guard(() async {
        final data = {
          'id': category.id,
          'type': category.type.name,
          'name': category.name!.trim(),
          'icon_key': category.iconKey,
          'color_key': category.colorKey,
          'is_archived': category.isArchived,
        };
        final row = isNew
            ? await _client.from('categories').insert(data).select().single()
            : await _client
                  .from('categories')
                  .update(data)
                  .eq('id', category.id)
                  .select()
                  .single();
        final saved = _categoryFromRow(row);
        _customCategories = {..._customCategories, saved.id: saved};
        return saved;
      });

  @override
  Future<void> deleteCategory(Category category) =>
      _guard(() => _client.from('categories').delete().eq('id', category.id));

  @override
  Future<MoneyTransaction> saveTransaction(
    MoneyTransaction transaction, {
    MoneyTransaction? previous,
  }) => _guard(() async {
    final photo = transaction.photo;
    String? photoPath = switch (photo) {
      RemoteTransactionPhoto(:final path) => path,
      _ => null,
    };
    String? uploadedPath;
    if (photo is PickedTransactionPhoto) {
      uploadedPath = await _upload(transaction.id, photo);
      photoPath = uploadedPath;
    }

    final row = _rowFromTransaction(transaction, photoPath);
    try {
      final saved = previous == null
          ? await _client.from('transactions').insert(row).select().single()
          : await _client
                .from('transactions')
                .update(row)
                .eq('id', transaction.id)
                .select()
                .single();

      // Clean up the old photo only after the row points elsewhere.
      final oldPath = switch (previous?.photo) {
        RemoteTransactionPhoto(:final path) => path,
        _ => null,
      };
      if (oldPath != null && oldPath != photoPath) {
        await _removePhoto(oldPath);
      }

      final urls = await _signedUrls([?photoPath]);
      return _transactionFromRow(saved, urls);
    } catch (_) {
      // The row was not saved: don't leave an orphaned upload behind.
      if (uploadedPath != null) await _removePhoto(uploadedPath);
      rethrow;
    }
  });

  @override
  Future<void> deleteTransaction(MoneyTransaction transaction) =>
      _guard(() async {
        await _client.from('transactions').delete().eq('id', transaction.id);
        if (transaction.photo case RemoteTransactionPhoto(:final path)) {
          await _removePhoto(path);
        }
      });

  Future<String> _upload(
    String transactionId,
    PickedTransactionPhoto photo,
  ) async {
    final bytes = await photo.file.readAsBytes();
    final mime = photo.file.mimeType ?? _mimeFromName(photo.file.name);
    final extension = switch (mime) {
      'image/png' => 'png',
      'image/heic' => 'heic',
      'image/webp' => 'webp',
      _ => 'jpg',
    };
    final path =
        '$_userId/$transactionId-${DateTime.now().millisecondsSinceEpoch}.$extension';
    await _photos.uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(contentType: mime, upsert: false),
    );
    return path;
  }

  /// Best effort: a leftover file is harmless, a failed delete must not
  /// fail the user's action.
  Future<void> _removePhoto(String path) async {
    try {
      await _photos.remove([path]);
    } catch (_) {}
  }

  Future<Map<String, String>> _signedUrls(List<String> paths) async {
    if (paths.isEmpty) return const {};
    final results = await _photos.createSignedUrlsResult(
      paths,
      _signedUrlSeconds,
    );
    return {
      for (final r in results)
        if (r case SignedUrlSuccess(:final path, :final signedUrl))
          path: signedUrl,
    };
  }

  static String _mimeFromName(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.heic')) return 'image/heic';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  static Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on LedgerException {
      rethrow;
    } on PostgrestException catch (e) {
      throw switch (e.code) {
        '23503' => const LedgerException.inUse(), // foreign key in use
        '23505' => const LedgerException.duplicate(), // unique violation
        _ => LedgerException(e),
      };
    } catch (e) {
      throw LedgerException(e);
    }
  }

  static Account _accountFromRow(Map<String, dynamic> r) => Account(
    id: r['id'] as String,
    name: r['name'] as String,
    type: r['type'] == 'bank' ? AccountType.bank : AccountType.cash,
    openingBalanceMinor: (r['opening_balance_minor'] as num).toInt(),
  );

  static Map<String, dynamic> _rowFromAccount(Account a) => {
    'id': a.id,
    'name': a.name.trim(),
    'type': a.type.name,
    'opening_balance_minor': a.openingBalanceMinor,
  };

  static Category _categoryFromRow(Map<String, dynamic> r) => Category.custom(
    id: r['id'] as String,
    type: TransactionType.values.byName(r['type'] as String),
    name: r['name'] as String,
    iconKey: r['icon_key'] as String,
    colorKey: r['color_key'] as String,
    isArchived: r['is_archived'] as bool? ?? false,
  );

  MoneyTransaction _transactionFromRow(
    Map<String, dynamic> r,
    Map<String, String> urls,
  ) {
    final type = TransactionType.values.byName(r['type'] as String);
    final path = r['photo_path'] as String?;
    return MoneyTransaction(
      id: r['id'] as String,
      type: type,
      amountMinor: (r['amount_minor'] as num).toInt(),
      occurredAt: DateTime.parse(r['occurred_at'] as String).toLocal(),
      accountId: r['account_id'] as String?,
      category: _resolveCategory(
        r['category_code'] as String?,
        r['custom_category_id'] as String?,
        type,
      ),
      sourceAccountId: r['source_account_id'] as String?,
      destinationAccountId: r['destination_account_id'] as String?,
      note: r['note'] as String?,
      // A missing file keeps its path; the UI falls back to the category icon.
      photo: path == null
          ? null
          : RemoteTransactionPhoto(path, urls[path] ?? ''),
    );
  }

  Category? _resolveCategory(
    String? code,
    String? customId,
    TransactionType type,
  ) {
    if (type == TransactionType.transfer) return null;
    final custom = customId == null ? null : _customCategories[customId];
    if (custom != null) return custom;
    for (final c in CategoryCode.values) {
      if (c.name == code && c.type == type) return Category.system(c);
    }
    // Unknown code or missing custom category: keep the row readable.
    return Category.system(
      type == TransactionType.income
          ? CategoryCode.otherIncome
          : CategoryCode.otherExpense,
    );
  }

  static Map<String, dynamic> _rowFromTransaction(
    MoneyTransaction t,
    String? photoPath,
  ) => {
    'id': t.id,
    'type': t.type.name,
    'amount_minor': t.amountMinor,
    'occurred_at': t.occurredAt.toUtc().toIso8601String(),
    'account_id': t.accountId,
    'category_code': t.category?.code?.name,
    'custom_category_id': t.category?.customId,
    'source_account_id': t.sourceAccountId,
    'destination_account_id': t.destinationAccountId,
    'note': t.note,
    'photo_path': photoPath,
  };
}
