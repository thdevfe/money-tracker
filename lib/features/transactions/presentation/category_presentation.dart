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
}
