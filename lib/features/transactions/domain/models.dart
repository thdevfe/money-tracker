import 'package:flutter/painting.dart';
import 'package:image_picker/image_picker.dart';

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

/// A transaction category: either a built-in one (identified by its
/// [CategoryCode], label localized in the UI) or a user-created one with its
/// own name, icon and color. Equality is by [id].
class Category {
  /// Set for built-in categories.
  final CategoryCode? code;

  /// Set for custom categories.
  final String? customId;
  final TransactionType? _customType;

  /// User-entered name of a custom category, shown as-is in every locale.
  final String? name;

  /// Keys into the app's icon and color palettes (custom categories only).
  final String? iconKey;
  final String? colorKey;

  /// Archived categories stay on old transactions but can't be picked.
  final bool isArchived;

  const Category.system(CategoryCode this.code)
    : customId = null,
      _customType = null,
      name = null,
      iconKey = null,
      colorKey = null,
      isArchived = false;

  const Category.custom({
    required String id,
    required TransactionType type,
    required String this.name,
    required String this.iconKey,
    required String this.colorKey,
    this.isArchived = false,
  }) : code = null,
       customId = id,
       _customType = type;

  bool get isSystem => code != null;

  String get id => code?.name ?? customId!;

  /// Income or expense.
  TransactionType get type => code?.type ?? _customType!;

  Category copyWith({
    String? name,
    String? iconKey,
    String? colorKey,
    bool? isArchived,
  }) {
    assert(!isSystem, 'Built-in categories are read-only');
    return Category.custom(
      id: customId!,
      type: type,
      name: name ?? this.name!,
      iconKey: iconKey ?? this.iconKey!,
      colorKey: colorKey ?? this.colorKey!,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  /// All built-in categories of [type].
  static List<Category> systemFor(TransactionType type) =>
      CategoryCode.forType(type).map(Category.system).toList();

  @override
  bool operator ==(Object other) => other is Category && other.id == id;

  @override
  int get hashCode => id.hashCode;
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

/// Photo picked or captured on this device, not uploaded yet. Kept as an
/// [XFile] so its bytes can be read on every platform, including web.
class PickedTransactionPhoto extends TransactionPhoto {
  final XFile file;
  final ImageProvider _provider;

  const PickedTransactionPhoto(this.file, this._provider);

  @override
  ImageProvider get imageProvider => _provider;
}

/// Photo stored in the backend, shown through a short-lived signed URL.
class RemoteTransactionPhoto extends TransactionPhoto {
  /// Storage path, e.g. `<user_id>/<file>.jpg`.
  final String path;
  final String url;

  const RemoteTransactionPhoto(this.path, this.url);

  @override
  ImageProvider get imageProvider => NetworkImage(url);
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
  final Category? category;

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

  /// Same transaction showing an updated version of its category.
  MoneyTransaction withCategory(Category category) => MoneyTransaction(
    id: id,
    type: type,
    amountMinor: amountMinor,
    occurredAt: occurredAt,
    accountId: accountId,
    category: category,
    sourceAccountId: sourceAccountId,
    destinationAccountId: destinationAccountId,
    note: note,
    photo: photo,
  );
}
