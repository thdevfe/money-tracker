import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/models.dart';

extension CategoryPresentation on CategoryCode {
  IconData get icon => switch (this) {
    CategoryCode.food => Icons.restaurant_rounded,
    CategoryCode.transport => Icons.directions_car_rounded,
    CategoryCode.shopping => Icons.shopping_bag_rounded,
    CategoryCode.bills => Icons.receipt_long_rounded,
    CategoryCode.housing => Icons.home_rounded,
    CategoryCode.health => Icons.medical_services_rounded,
    CategoryCode.entertainment => Icons.movie_rounded,
    CategoryCode.education => Icons.school_rounded,
    CategoryCode.travel => Icons.flight_rounded,
    CategoryCode.personalCare => Icons.spa_rounded,
    CategoryCode.otherExpense => Icons.more_horiz_rounded,
    CategoryCode.salary => Icons.payments_rounded,
    CategoryCode.freelance => Icons.laptop_mac_rounded,
    CategoryCode.business => Icons.storefront_rounded,
    CategoryCode.investment => Icons.trending_up_rounded,
    CategoryCode.gift => Icons.card_giftcard_rounded,
    CategoryCode.otherIncome => Icons.add_card_rounded,
  };

  /// Tile color used where a transaction has no photo.
  Color get tint => switch (this) {
    CategoryCode.food => const Color(0xFFF08C3A),
    CategoryCode.transport => const Color(0xFF3B82F6),
    CategoryCode.shopping => const Color(0xFFE5579A),
    CategoryCode.bills => const Color(0xFFD99A1E),
    CategoryCode.housing => const Color(0xFF8D6E63),
    CategoryCode.health => const Color(0xFFE5484D),
    CategoryCode.entertainment => const Color(0xFF8B5CF6),
    CategoryCode.education => const Color(0xFF5B6CF0),
    CategoryCode.travel => const Color(0xFF14B8A6),
    CategoryCode.personalCare => const Color(0xFFEC6FB0),
    CategoryCode.otherExpense => const Color(0xFF7C8796),
    CategoryCode.salary ||
    CategoryCode.freelance ||
    CategoryCode.business ||
    CategoryCode.investment ||
    CategoryCode.gift ||
    CategoryCode.otherIncome => const Color(0xFF16A36A),
  };

  String label(AppLocalizations l10n) => switch (this) {
    CategoryCode.food => l10n.catFood,
    CategoryCode.transport => l10n.catTransport,
    CategoryCode.shopping => l10n.catShopping,
    CategoryCode.bills => l10n.catBills,
    CategoryCode.housing => l10n.catHousing,
    CategoryCode.health => l10n.catHealth,
    CategoryCode.entertainment => l10n.catEntertainment,
    CategoryCode.education => l10n.catEducation,
    CategoryCode.travel => l10n.catTravel,
    CategoryCode.personalCare => l10n.catPersonalCare,
    CategoryCode.otherExpense => l10n.catOtherExpense,
    CategoryCode.salary => l10n.catSalary,
    CategoryCode.freelance => l10n.catFreelance,
    CategoryCode.business => l10n.catBusiness,
    CategoryCode.investment => l10n.catInvestment,
    CategoryCode.gift => l10n.catGift,
    CategoryCode.otherIncome => l10n.catOtherIncome,
  };
}

/// Icons a custom category can use, keyed for storage.
const categoryIconChoices = <String, IconData>{
  'restaurant': Icons.restaurant_rounded,
  'coffee': Icons.local_cafe_rounded,
  'groceries': Icons.local_grocery_store_rounded,
  'car': Icons.directions_car_rounded,
  'motorbike': Icons.two_wheeler_rounded,
  'fuel': Icons.local_gas_station_rounded,
  'shopping': Icons.shopping_bag_rounded,
  'home': Icons.home_rounded,
  'bolt': Icons.bolt_rounded,
  'phone': Icons.smartphone_rounded,
  'wifi': Icons.wifi_rounded,
  'health': Icons.medical_services_rounded,
  'fitness': Icons.fitness_center_rounded,
  'pets': Icons.pets_rounded,
  'child': Icons.child_care_rounded,
  'school': Icons.school_rounded,
  'book': Icons.menu_book_rounded,
  'game': Icons.sports_esports_rounded,
  'movie': Icons.movie_rounded,
  'music': Icons.music_note_rounded,
  'travel': Icons.flight_rounded,
  'beauty': Icons.spa_rounded,
  'gift': Icons.card_giftcard_rounded,
  'heart': Icons.favorite_rounded,
  'work': Icons.work_rounded,
  'money': Icons.payments_rounded,
  'savings': Icons.savings_rounded,
  'chart': Icons.trending_up_rounded,
  'star': Icons.star_rounded,
  'other': Icons.more_horiz_rounded,
};

/// Colors a custom category can use, keyed for storage.
const categoryColorChoices = <String, Color>{
  'orange': Color(0xFFF08C3A),
  'amber': Color(0xFFD99A1E),
  'red': Color(0xFFE5484D),
  'pink': Color(0xFFE5579A),
  'purple': Color(0xFF8B5CF6),
  'indigo': Color(0xFF5B6CF0),
  'blue': Color(0xFF3B82F6),
  'teal': Color(0xFF14B8A6),
  'green': Color(0xFF16A36A),
  'brown': Color(0xFF8D6E63),
  'slate': Color(0xFF7C8796),
};

extension CategoryDisplay on Category {
  IconData get icon =>
      code?.icon ?? categoryIconChoices[iconKey] ?? Icons.category_rounded;

  Color get tint =>
      code?.tint ?? categoryColorChoices[colorKey] ?? const Color(0xFF7C8796);

  String label(AppLocalizations l10n) => code?.label(l10n) ?? name ?? '';
}

extension TransactionTypePresentation on TransactionType {
  IconData get icon => switch (this) {
    TransactionType.expense => Icons.south_east_rounded,
    TransactionType.income => Icons.north_east_rounded,
    TransactionType.transfer => Icons.swap_horiz_rounded,
  };

  String label(AppLocalizations l10n) => switch (this) {
    TransactionType.expense => l10n.typeExpense,
    TransactionType.income => l10n.typeIncome,
    TransactionType.transfer => l10n.typeTransfer,
  };
}

extension AccountTypePresentation on AccountType {
  IconData get icon => switch (this) {
    AccountType.cash => Icons.account_balance_wallet_rounded,
    AccountType.bank => Icons.account_balance_rounded,
  };

  String label(AppLocalizations l10n) => switch (this) {
    AccountType.cash => l10n.accountTypeCash,
    AccountType.bank => l10n.accountTypeBank,
  };
}

extension TransactionDisplay on MoneyTransaction {
  /// Visible name: the note, or the category/transfer label when empty.
  String title(AppLocalizations l10n) {
    final text = note?.trim();
    if (text != null && text.isNotEmpty) return text;
    return category?.label(l10n) ?? type.label(l10n);
  }

  IconData get displayIcon => category?.icon ?? type.icon;

  Color get displayTint => category?.tint ?? const Color(0xFF3984D6);
}
