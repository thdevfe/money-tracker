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

  @override
  String get photoUpload => 'Upload photo';

  @override
  String get photoQuickHint => 'Snap a receipt or the moment. Optional.';

  @override
  String get detailsLabel => 'Details';

  @override
  String get typeShortExpense => 'Expense';

  @override
  String get typeShortIncome => 'Income';

  @override
  String get typeShortTransfer => 'Transfer';

  @override
  String get chooseFromLibrary => 'Choose from library';

  @override
  String get skipPhoto => 'Skip photo';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get cameraUnavailable =>
      'Tap to open the camera, or choose from your library.';

  @override
  String get flashOn => 'Turn flash on';

  @override
  String get flashOff => 'Turn flash off';

  @override
  String get switchCamera => 'Switch camera';

  @override
  String get addDetails => 'Add details';

  @override
  String get done => 'Done';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get retakePhoto => 'Take again';

  @override
  String get keypadClear => 'Clear';

  @override
  String get keypadBackspace => 'Delete last digit';

  @override
  String get chooseCategory => 'Choose category';

  @override
  String get signInTitle => 'Sign in';

  @override
  String get signUpTitle => 'Create account';

  @override
  String get signInSubtitle =>
      'Your data is saved to your account and private to you.';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get signInAction => 'Sign in';

  @override
  String get signUpAction => 'Create account';

  @override
  String get switchToSignUp => 'No account yet? Create one';

  @override
  String get switchToSignIn => 'Already have an account? Sign in';

  @override
  String get errorEmailInvalid => 'Enter a valid email';

  @override
  String get errorPasswordShort => 'Use at least 6 characters';

  @override
  String get authInvalidCredentials => 'Wrong email or password';

  @override
  String get authEmailNotConfirmed => 'Confirm your email first, then sign in.';

  @override
  String get authUserExists =>
      'This email already has an account. Sign in instead.';

  @override
  String get authWeakPassword => 'Choose a stronger password';

  @override
  String get authNetwork => 'Can\'t reach the server. Check your connection.';

  @override
  String get authUnknown => 'Something went wrong. Try again.';

  @override
  String get confirmEmailSent =>
      'Check your email to confirm your account, then sign in.';

  @override
  String get signOut => 'Sign out';

  @override
  String signedInAs(String email) {
    return 'Signed in as $email';
  }

  @override
  String get loadErrorTitle => 'Couldn\'t load your data';

  @override
  String get loadErrorMessage => 'Check your connection and try again.';

  @override
  String get retry => 'Try again';

  @override
  String get saveFailed => 'Couldn\'t save. Your entry is kept; try again.';

  @override
  String get deleteFailed => 'Couldn\'t delete. Try again.';

  @override
  String get errorInsufficientBalance => 'Not enough money in this account';

  @override
  String get noAccountsTitle => 'No accounts yet';

  @override
  String get dataCloudNote =>
      'Your data is stored in your Supabase account. Only you can see it.';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get manageCategories => 'Manage categories';

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get builtInBadge => 'Built-in';

  @override
  String get archivedSection => 'Archived';

  @override
  String get addCategory => 'Add category';

  @override
  String get editCategory => 'Edit category';

  @override
  String get categoryNameLabel => 'Category name';

  @override
  String get iconLabel => 'Icon';

  @override
  String get colorLabel => 'Color';

  @override
  String get archiveAction => 'Archive';

  @override
  String get restoreAction => 'Restore';

  @override
  String get categoryInUseMessage =>
      'Transactions use this category, so it can\'t be deleted. Archive it to hide it from new transactions.';

  @override
  String get deleteCategoryTitle => 'Delete this category?';

  @override
  String get builtInReadOnly => 'Built-in categories can\'t be changed.';

  @override
  String get errorNameRequired => 'Enter a name';

  @override
  String get errorNameTooLong => 'This name is too long';

  @override
  String get errorNameDuplicate => 'This name is already used';

  @override
  String get addAccount => 'Add account';

  @override
  String get editAccount => 'Edit account';

  @override
  String get accountNameLabel => 'Account name';

  @override
  String get accountNameHint => 'e.g. Cash wallet';

  @override
  String get accountTypeLabel => 'Type';

  @override
  String get openingBalanceLabel => 'Opening balance';

  @override
  String get openingBalanceHelp =>
      'Money already in this account. It isn\'t counted as income.';

  @override
  String get openingBalanceLocked =>
      'The opening balance can\'t change once the account has transactions.';

  @override
  String get deleteAccountTitle => 'Delete this account?';

  @override
  String get accountInUseMessage =>
      'This account has transactions, so it can\'t be deleted. Delete those transactions first.';

  @override
  String get currentBalanceLabel => 'Current balance';

  @override
  String get recentTransactions => 'Recent transactions';

  @override
  String get noAccountsMessage =>
      'Create a wallet or bank account to start recording money.';

  @override
  String get savedMessage => 'Saved';

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String get filterTime => 'Time';

  @override
  String get periodAnyTime => 'Any time';

  @override
  String get periodThisMonth => 'This month';

  @override
  String get periodLastMonth => 'Last month';

  @override
  String get periodCustom => 'Choose dates…';

  @override
  String get allAccounts => 'All accounts';

  @override
  String get allCategories => 'All categories';

  @override
  String get resetFilters => 'Reset filters';

  @override
  String dateRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String resultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions',
      one: '1 transaction',
    );
    return '$_temp0';
  }

  @override
  String get customizeGrid => 'Customize calendar';

  @override
  String get gridShape => 'Shape';

  @override
  String get shapeRounded => 'Rounded';

  @override
  String get shapeCircle => 'Circle';

  @override
  String get shapeSquare => 'Square';

  @override
  String get gridDisplay => 'Display';

  @override
  String get displaySingle => 'Single';

  @override
  String get displayStacked => 'Stacked';

  @override
  String get displayFan => 'Fan';

  @override
  String get gridBorder => 'Border';

  @override
  String get borderAccent => 'Accent';

  @override
  String get borderNone => 'None';

  @override
  String get borderThin => 'Thin';

  @override
  String get borderColor => 'Border color';

  @override
  String get colorAuto => 'Auto';

  @override
  String get badgeSection => 'Badge';

  @override
  String get showCountBadge => 'Show count badge';

  @override
  String get monthStartDay => 'Month start day';

  @override
  String get monthStartDayHelp =>
      'Each monthly period starts on this day, for example your payday (default: 1st).';

  @override
  String get saveAndAddNext => 'Add';

  @override
  String get chooseDay => 'Select day';

  @override
  String get noteShort => 'Note';

  @override
  String get bulkEntry => 'Bulk entry';

  @override
  String get bulkHint =>
      'One transaction per line, e.g.\ncoffee 35k\ngrab 52k\nlunch 1tr2\n+salary 15tr';

  @override
  String get paste => 'Paste';

  @override
  String get bulkEmptyTitle => 'As quick as jotting a note';

  @override
  String get bulkEmptyBody =>
      'Type or paste your spending list. The app picks out the amounts and guesses the categories.';

  @override
  String get bulkNoAmount => 'No amount found';

  @override
  String bulkSave(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Save $count transactions',
      one: 'Save 1 transaction',
      zero: 'Nothing to save yet',
    );
    return '$_temp0';
  }

  @override
  String bulkSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Added $count transactions',
      one: 'Added 1 transaction',
    );
    return '$_temp0';
  }

  @override
  String get layoutGrid => 'Photo grid';

  @override
  String get layoutList => 'List';

  @override
  String get layoutCalendar => 'Calendar';

  @override
  String get layoutChart => 'Chart';

  @override
  String switchLayout(String current) {
    return 'Change layout: $current';
  }

  @override
  String get expenseShort => 'Exp';

  @override
  String get incomeShort => 'Inc';

  @override
  String get dailySpending => 'Spending by day';

  @override
  String get addNotePlaceholder => 'Add a note…';

  @override
  String get editDetails => 'Edit details';

  @override
  String get moreActions => 'More actions';

  @override
  String viewerPosition(int index, int count) {
    return '$index / $count';
  }

  @override
  String dateAtTime(String date, String time) {
    return '$date at $time';
  }

  @override
  String get close => 'Close';
}
