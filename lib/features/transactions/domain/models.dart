import 'package:flutter/painting.dart';

enum TransactionType { expense, income, transfer }

enum AccountType { cash, bank }

class Account {
  final String id;

  /// User-entered name; shown as-is in every locale.
  final String name;
  final AccountType type;
  final int openingBalanceMinor;

  const Account({
    required this.id,
    required this.name,
    required this.type,
    this.openingBalanceMinor = 0,
  });
}

/// System categories. The enum name is the stable code; labels are localized
/// in the presentation layer.
enum CategoryCode {
  food(TransactionType.expense),
  transport(TransactionType.expense),
  shopping(TransactionType.expense),
  bills(TransactionType.expense),
  housing(TransactionType.expense),
  health(TransactionType.expense),
  entertainment(TransactionType.expense),
  education(TransactionType.expense),
  travel(TransactionType.expense),
  personalCare(TransactionType.expense),
  otherExpense(TransactionType.expense),
  salary(TransactionType.income),
  freelance(TransactionType.income),
  business(TransactionType.income),
  investment(TransactionType.income),
  gift(TransactionType.income),
  otherIncome(TransactionType.income);

  final TransactionType type;

  const CategoryCode(this.type);

  static List<CategoryCode> forType(TransactionType type) =>
      values.where((c) => c.type == type).toList();
}

/// An optional photo attached to a transaction.
sealed class TransactionPhoto {
  const TransactionPhoto();

  ImageProvider get imageProvider;
}

/// Bundled sample photo used by the mock data.
class AssetTransactionPhoto extends TransactionPhoto {
  final String assetName;

  const AssetTransactionPhoto(this.assetName);

  @override
  ImageProvider get imageProvider => AssetImage(assetName);
}

/// Photo picked by the user. For this prototype the path points at the
/// picker's temporary file and is not copied to app storage.
class PickedTransactionPhoto extends TransactionPhoto {
  final String path;
  final ImageProvider _provider;

  const PickedTransactionPhoto(this.path, this._provider);

  @override
  ImageProvider get imageProvider => _provider;
}

class MoneyTransaction {
  final String id;
  final TransactionType type;

  /// Positive integer amount in minor units (đồng for VND).
  final int amountMinor;

  /// Local date/time of the transaction.
  final DateTime occurredAt;

  /// Income/expense only.
  final String? accountId;
  final CategoryCode? category;

  /// Transfer only.
  final String? sourceAccountId;
  final String? destinationAccountId;

  final String? note;
  final TransactionPhoto? photo;

  const MoneyTransaction({
    required this.id,
    required this.type,
    required this.amountMinor,
    required this.occurredAt,
    this.accountId,
    this.category,
    this.sourceAccountId,
    this.destinationAccountId,
    this.note,
    this.photo,
  });

  bool get hasPhoto => photo != null;
}
