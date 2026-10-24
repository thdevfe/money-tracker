// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Money Tracker';

  @override
  String get navHome => 'Home';

  @override
  String get navTransactions => 'Transactions';

  @override
  String get navAdd => 'Add transaction';

  @override
  String get navReports => 'Reports';

  @override
  String get navAccounts => 'Accounts';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get goToToday => 'Today';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get summaryBalance => 'Total balance';

  @override
  String get summaryIncome => 'Income';

  @override
  String get summaryExpense => 'Expenses';

  @override
  String summaryMonthCaption(String month) {
    return 'In $month';
  }

  @override
  String get calendarLegendExpense => 'Daily spending';

  @override
  String get calendarLegendIncome => 'Income';

  @override
  String calendarDaySemantics(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions',
      one: '1 transaction',
      zero: 'No transactions',
    );
    return '$date. $_temp0';
  }

  @override
  String get calendarSelected => 'Selected';

  @override
  String morePhotosSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more photos',
      one: '1 more photo',
    );
    return '$_temp0';
  }

  @override
  String compactThousands(String value) {
    return '${value}k';
  }

  @override
  String compactMillions(String value) {
    return '${value}M';
  }

  @override
  String compactBillions(String value) {
    return '${value}B';
  }

  @override
  String expenseAmountSemantics(String amount) {
    return 'Expenses $amount';
  }

  @override
  String incomeAmountSemantics(String amount) {
    return 'Income $amount';
  }

  @override
  String transferAmountSemantics(String amount) {
    return 'Transfer $amount';
  }

  @override
  String get dayExpenseLabel => 'Spent';

  @override
  String get dayIncomeLabel => 'Received';

  @override
  String get viewAll => 'View all';

  @override
  String moreTransactions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count more transactions',
      one: '+1 more transaction',
    );
    return '$_temp0';
  }

  @override
  String get dayEmptyTitle => 'Nothing recorded';

  @override
  String get dayEmptyMessage => 'Add an expense or income for this day.';

  @override
  String get monthEmptyTitle => 'No transactions this month';

  @override
  String get monthEmptyMessage =>
      'Tap + to record an expense or income. Photos are optional.';

  @override
  String get addTransaction => 'Add transaction';

  @override
  String get filterAll => 'All';

  @override
  String get typeExpense => 'Expense';

  @override
  String get typeIncome => 'Income';

  @override
  String get typeTransfer => 'Transfer';

  @override
  String get filterEmptyTitle => 'No matching transactions';

  @override
  String get filterEmptyMessage => 'Try a different filter or search.';

  @override
  String get showAll => 'Show all';

  @override
  String get transactionsEmptyTitle => 'No transactions yet';

  @override
  String get transactionsEmptyMessage =>
      'Your expenses, income and transfers will appear here.';

  @override
  String get search => 'Search';

  @override
  String get closeSearch => 'Close search';

  @override
  String get searchHint => 'Search notes or categories';

  @override
  String transferRoute(String from, String to) {
    return '$from → $to';
  }

  @override
  String get addTitle => 'New transaction';

  @override
  String get editTitle => 'Edit transaction';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get amountLabel => 'Amount';

  @override
  String get categoryLabel => 'Category';

  @override
  String get accountLabel => 'Account';

  @override
  String get fromAccountLabel => 'From account';

  @override
  String get toAccountLabel => 'To account';

  @override
  String get dateLabel => 'Date';

  @override
  String get timeLabel => 'Time';

  @override
  String get noteLabel => 'Note (optional)';

  @override
  String get noteHint => 'e.g. Lunch with the team';

  @override
  String get photoLabel => 'Photo (optional)';

  @override
  String get photoHelp => 'You can save without a photo.';

  @override
  String get photoCamera => 'Camera';

  @override
  String get photoLibrary => 'Photo library';

  @override
  String get photoReplace => 'Replace';

  @override
  String get photoRemove => 'Remove';

  @override
  String get photoPreviewSemantics => 'Attached photo';

  @override
  String get photoPickError =>
      'Couldn\'t open photos. You can still save without one.';

  @override
  String get typeLockedHint => 'The type can\'t be changed while editing.';

  @override
  String get errorAmountRequired => 'Enter an amount';

  @override
  String get errorAmountPositive => 'Amount must be greater than 0';

  @override
  String get errorAmountTooLarge => 'Amount is too large';

  @override
  String get errorCategoryRequired => 'Choose a category';

  @override
  String get errorSameAccount => 'Choose two different accounts';

  @override
  String get savedAdded => 'Transaction added';

  @override
  String get savedUpdated => 'Changes saved';

  @override
  String get deleted => 'Transaction deleted';

  @override
  String get delete => 'Delete';

  @override
  String get deleteConfirmTitle => 'Delete this transaction?';

  @override
  String get deleteConfirmMessage => 'This can\'t be undone.';

  @override
  String get discardTitle => 'Discard changes?';

  @override
  String get discardMessage => 'Your unsaved changes will be lost.';

  @override
  String get discard => 'Discard';

  @override
  String get keepEditing => 'Keep editing';

  @override
  String get catFood => 'Food & Drinks';

  @override
  String get catTransport => 'Transport';

  @override
  String get catShopping => 'Shopping';

  @override
  String get catBills => 'Bills & Utilities';

  @override
  String get catHousing => 'Housing';

  @override
  String get catHealth => 'Health';

  @override
  String get catEntertainment => 'Entertainment';

  @override
  String get catEducation => 'Education';

  @override
  String get catTravel => 'Travel';

  @override
  String get catPersonalCare => 'Personal care';

  @override
  String get catOtherExpense => 'Other';

  @override
  String get catSalary => 'Salary';

  @override
  String get catFreelance => 'Freelance';

  @override
  String get catBusiness => 'Business';

  @override
  String get catInvestment => 'Investment';

  @override
  String get catGift => 'Gift';

  @override
  String get catOtherIncome => 'Other income';

  @override
  String get accountTypeCash => 'Cash';

  @override
  String get accountTypeBank => 'Bank account';

  @override
  String get accountsTotalLabel => 'Total balance of tracked accounts';

  @override
  String get accountsLaterNote =>
      'Creating and editing accounts comes in a later milestone.';

  @override
  String get reportsComingTitle => 'Reports are coming soon';

  @override
  String get reportsComingMessage =>
      'Spending by category will appear here in a later milestone.';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsCurrency => 'Currency';

  @override
  String get currencyVnd => 'Vietnamese đồng (VND)';

  @override
  String get settingsData => 'Data';

  @override
  String get dataPrototypeNote =>
      'Prototype: sample data lives in memory and resets when the app restarts. Nothing leaves this device.';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get defaultUserName => 'Friend';

  @override
  String spentToday(String amount) {
    return 'Spent $amount today';
  }

  @override
  String get viewDay => 'Day';

  @override
  String get viewMonth => 'Month';

  @override
  String get hideAmounts => 'Hide amounts';

  @override
  String get showAmounts => 'Show amounts';

  @override
  String get chooseMonth => 'Choose month';

  @override
  String get previousYear => 'Previous year';

  @override
  String get nextYear => 'Next year';

  @override
  String get previousDay => 'Previous day';

  @override
  String get nextDay => 'Next day';

  @override
  String get navProfile => 'Profile';

  @override
  String get profileName => 'Your name';

  @override
  String get openProfile => 'Open profile';

  @override
  String moreItemsSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more transactions',
      one: '1 more transaction',
    );
    return '$_temp0';
  }

  @override
  String get periodMonth => 'Month';

  @override
  String get periodYear => 'Year';

  @override
  String get periodAllTime => 'All time';

  @override
  String get allTimeTitle => 'All time';

  @override
  String get reportsBalance => 'Balance';

  @override
  String get savingsRate => 'Savings rate';

  @override
  String get tabCluster => 'Cluster';

  @override
  String get tabMap => 'Map';

  @override
  String get laterVersionTitle => 'Coming in a later version';

  @override
  String get laterVersionMessage =>
      'This view is planned after the core features are done.';

  @override
  String get reportsNoExpenses => 'No expenses in this period';

  @override
  String categoryShareDetail(int count, String percent) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions',
      one: '1 transaction',
    );
    return '$_temp0 · $percent';
  }
}
