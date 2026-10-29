import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Money Tracker'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navTransactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get navTransactions;

  /// No description provided for @navAdd.
  ///
  /// In en, this message translates to:
  /// **'Add transaction'**
  String get navAdd;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @navAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get navAccounts;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @goToToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get goToToday;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @summaryBalance.
  ///
  /// In en, this message translates to:
  /// **'Total balance'**
  String get summaryBalance;

  /// No description provided for @summaryIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get summaryIncome;

  /// No description provided for @summaryExpense.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get summaryExpense;

  /// No description provided for @summaryMonthCaption.
  ///
  /// In en, this message translates to:
  /// **'In {month}'**
  String summaryMonthCaption(String month);

  /// No description provided for @calendarLegendExpense.
  ///
  /// In en, this message translates to:
  /// **'Daily spending'**
  String get calendarLegendExpense;

  /// No description provided for @calendarLegendIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get calendarLegendIncome;

  /// No description provided for @calendarDaySemantics.
  ///
  /// In en, this message translates to:
  /// **'{date}. {count, plural, =0{No transactions} =1{1 transaction} other{{count} transactions}}'**
  String calendarDaySemantics(String date, int count);

  /// No description provided for @calendarSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get calendarSelected;

  /// No description provided for @morePhotosSemantics.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 more photo} other{{count} more photos}}'**
  String morePhotosSemantics(int count);

  /// No description provided for @compactThousands.
  ///
  /// In en, this message translates to:
  /// **'{value}k'**
  String compactThousands(String value);

  /// No description provided for @compactMillions.
  ///
  /// In en, this message translates to:
  /// **'{value}M'**
  String compactMillions(String value);

  /// No description provided for @compactBillions.
  ///
  /// In en, this message translates to:
  /// **'{value}B'**
  String compactBillions(String value);

  /// No description provided for @expenseAmountSemantics.
  ///
  /// In en, this message translates to:
  /// **'Expenses {amount}'**
  String expenseAmountSemantics(String amount);

  /// No description provided for @incomeAmountSemantics.
  ///
  /// In en, this message translates to:
  /// **'Income {amount}'**
  String incomeAmountSemantics(String amount);

  /// No description provided for @transferAmountSemantics.
  ///
  /// In en, this message translates to:
  /// **'Transfer {amount}'**
  String transferAmountSemantics(String amount);

  /// No description provided for @dayExpenseLabel.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get dayExpenseLabel;

  /// No description provided for @dayIncomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get dayIncomeLabel;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @moreTransactions.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{+1 more transaction} other{+{count} more transactions}}'**
  String moreTransactions(int count);

  /// No description provided for @dayEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing recorded'**
  String get dayEmptyTitle;

  /// No description provided for @dayEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add an expense or income for this day.'**
  String get dayEmptyMessage;

  /// No description provided for @monthEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No transactions this month'**
  String get monthEmptyTitle;

  /// No description provided for @monthEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap + to record an expense or income. Photos are optional.'**
  String get monthEmptyMessage;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add transaction'**
  String get addTransaction;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @typeExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get typeExpense;

  /// No description provided for @typeIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get typeIncome;

  /// No description provided for @typeTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get typeTransfer;

  /// No description provided for @filterEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No matching transactions'**
  String get filterEmptyTitle;

  /// No description provided for @filterEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Try a different filter or search.'**
  String get filterEmptyMessage;

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get showAll;

  /// No description provided for @transactionsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get transactionsEmptyTitle;

  /// No description provided for @transactionsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Your expenses, income and transfers will appear here.'**
  String get transactionsEmptyMessage;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @closeSearch.
  ///
  /// In en, this message translates to:
  /// **'Close search'**
  String get closeSearch;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search notes or categories'**
  String get searchHint;

  /// No description provided for @transferRoute.
  ///
  /// In en, this message translates to:
  /// **'{from} → {to}'**
  String transferRoute(String from, String to);

  /// No description provided for @addTitle.
  ///
  /// In en, this message translates to:
  /// **'New transaction'**
  String get addTitle;

  /// No description provided for @editTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit transaction'**
  String get editTitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @accountLabel.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountLabel;

  /// No description provided for @fromAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'From account'**
  String get fromAccountLabel;

  /// No description provided for @toAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'To account'**
  String get toAccountLabel;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @noteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteLabel;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Lunch with the team'**
  String get noteHint;

  /// No description provided for @photoLabel.
  ///
  /// In en, this message translates to:
  /// **'Photo (optional)'**
  String get photoLabel;

  /// No description provided for @photoHelp.
  ///
  /// In en, this message translates to:
  /// **'You can save without a photo.'**
  String get photoHelp;

  /// No description provided for @photoCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get photoCamera;

  /// No description provided for @photoLibrary.
  ///
  /// In en, this message translates to:
  /// **'Photo library'**
  String get photoLibrary;

  /// No description provided for @photoReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get photoReplace;

  /// No description provided for @photoRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get photoRemove;

  /// No description provided for @photoPreviewSemantics.
  ///
  /// In en, this message translates to:
  /// **'Attached photo'**
  String get photoPreviewSemantics;

  /// No description provided for @photoPickError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open photos. You can still save without one.'**
  String get photoPickError;

  /// No description provided for @typeLockedHint.
  ///
  /// In en, this message translates to:
  /// **'The type can\'t be changed while editing.'**
  String get typeLockedHint;

  /// No description provided for @errorAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount'**
  String get errorAmountRequired;

  /// No description provided for @errorAmountPositive.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than 0'**
  String get errorAmountPositive;

  /// No description provided for @errorAmountTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Amount is too large'**
  String get errorAmountTooLarge;

  /// No description provided for @errorCategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a category'**
  String get errorCategoryRequired;

  /// No description provided for @errorSameAccount.
  ///
  /// In en, this message translates to:
  /// **'Choose two different accounts'**
  String get errorSameAccount;

  /// No description provided for @savedAdded.
  ///
  /// In en, this message translates to:
  /// **'Transaction added'**
  String get savedAdded;

  /// No description provided for @savedUpdated.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get savedUpdated;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted'**
  String get deleted;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this transaction?'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This can\'t be undone.'**
  String get deleteConfirmMessage;

  /// No description provided for @discardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardTitle;

  /// No description provided for @discardMessage.
  ///
  /// In en, this message translates to:
  /// **'Your unsaved changes will be lost.'**
  String get discardMessage;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @keepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get keepEditing;

  /// No description provided for @catFood.
  ///
  /// In en, this message translates to:
  /// **'Food & Drinks'**
  String get catFood;

  /// No description provided for @catTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get catTransport;

  /// No description provided for @catShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get catShopping;

  /// No description provided for @catBills.
  ///
  /// In en, this message translates to:
  /// **'Bills & Utilities'**
  String get catBills;

  /// No description provided for @catHousing.
  ///
  /// In en, this message translates to:
  /// **'Housing'**
  String get catHousing;

  /// No description provided for @catHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get catHealth;

  /// No description provided for @catEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get catEntertainment;

  /// No description provided for @catEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get catEducation;

  /// No description provided for @catTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get catTravel;

  /// No description provided for @catPersonalCare.
  ///
  /// In en, this message translates to:
  /// **'Personal care'**
  String get catPersonalCare;

  /// No description provided for @catOtherExpense.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get catOtherExpense;

  /// No description provided for @catSalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get catSalary;

  /// No description provided for @catFreelance.
  ///
  /// In en, this message translates to:
  /// **'Freelance'**
  String get catFreelance;

  /// No description provided for @catBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get catBusiness;

  /// No description provided for @catInvestment.
  ///
  /// In en, this message translates to:
  /// **'Investment'**
  String get catInvestment;

  /// No description provided for @catGift.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get catGift;

  /// No description provided for @catOtherIncome.
  ///
  /// In en, this message translates to:
  /// **'Other income'**
  String get catOtherIncome;

  /// No description provided for @accountTypeCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get accountTypeCash;

  /// No description provided for @accountTypeBank.
  ///
  /// In en, this message translates to:
  /// **'Bank account'**
  String get accountTypeBank;

  /// No description provided for @accountsTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total balance of tracked accounts'**
  String get accountsTotalLabel;

  /// No description provided for @accountsLaterNote.
  ///
  /// In en, this message translates to:
  /// **'Creating and editing accounts comes in a later milestone.'**
  String get accountsLaterNote;

  /// No description provided for @reportsComingTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports are coming soon'**
  String get reportsComingTitle;

  /// No description provided for @reportsComingMessage.
  ///
  /// In en, this message translates to:
  /// **'Spending by category will appear here in a later milestone.'**
  String get reportsComingMessage;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Tiếng Việt'**
  String get languageVietnamese;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @settingsCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get settingsCurrency;

  /// No description provided for @currencyVnd.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese đồng (VND)'**
  String get currencyVnd;

  /// No description provided for @settingsData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsData;

  /// No description provided for @dataPrototypeNote.
  ///
  /// In en, this message translates to:
  /// **'Prototype: sample data lives in memory and resets when the app restarts. Nothing leaves this device.'**
  String get dataPrototypeNote;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @defaultUserName.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get defaultUserName;

  /// No description provided for @spentToday.
  ///
  /// In en, this message translates to:
  /// **'Spent {amount} today'**
  String spentToday(String amount);

  /// No description provided for @viewDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get viewDay;

  /// No description provided for @viewMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get viewMonth;

  /// No description provided for @hideAmounts.
  ///
  /// In en, this message translates to:
  /// **'Hide amounts'**
  String get hideAmounts;

  /// No description provided for @showAmounts.
  ///
  /// In en, this message translates to:
  /// **'Show amounts'**
  String get showAmounts;

  /// No description provided for @chooseMonth.
  ///
  /// In en, this message translates to:
  /// **'Choose month'**
  String get chooseMonth;

  /// No description provided for @previousYear.
  ///
  /// In en, this message translates to:
  /// **'Previous year'**
  String get previousYear;

  /// No description provided for @nextYear.
  ///
  /// In en, this message translates to:
  /// **'Next year'**
  String get nextYear;

  /// No description provided for @previousDay.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get previousDay;

  /// No description provided for @nextDay.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get nextDay;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get profileName;

  /// No description provided for @openProfile.
  ///
  /// In en, this message translates to:
  /// **'Open profile'**
  String get openProfile;

  /// No description provided for @moreItemsSemantics.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 more transaction} other{{count} more transactions}}'**
  String moreItemsSemantics(int count);

  /// No description provided for @periodMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get periodMonth;

  /// No description provided for @periodYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get periodYear;

  /// No description provided for @periodAllTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get periodAllTime;

  /// No description provided for @allTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get allTimeTitle;

  /// No description provided for @reportsBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get reportsBalance;

  /// No description provided for @savingsRate.
  ///
  /// In en, this message translates to:
  /// **'Savings rate'**
  String get savingsRate;

  /// No description provided for @tabCluster.
  ///
  /// In en, this message translates to:
  /// **'Cluster'**
  String get tabCluster;

  /// No description provided for @tabMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get tabMap;

  /// No description provided for @laterVersionTitle.
  ///
  /// In en, this message translates to:
  /// **'Coming in a later version'**
  String get laterVersionTitle;

  /// No description provided for @laterVersionMessage.
  ///
  /// In en, this message translates to:
  /// **'This view is planned after the core features are done.'**
  String get laterVersionMessage;

  /// No description provided for @reportsNoExpenses.
  ///
  /// In en, this message translates to:
  /// **'No expenses in this period'**
  String get reportsNoExpenses;

  /// No description provided for @categoryShareDetail.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 transaction} other{{count} transactions}} · {percent}'**
  String categoryShareDetail(int count, String percent);

  /// No description provided for @photoUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload photo'**
  String get photoUpload;

  /// No description provided for @photoQuickHint.
  ///
  /// In en, this message translates to:
  /// **'Snap a receipt or the moment. Optional.'**
  String get photoQuickHint;

  /// No description provided for @detailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailsLabel;

  /// No description provided for @typeShortExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get typeShortExpense;

  /// No description provided for @typeShortIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get typeShortIncome;

  /// No description provided for @typeShortTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get typeShortTransfer;

  /// No description provided for @chooseFromLibrary.
  ///
  /// In en, this message translates to:
  /// **'Choose from library'**
  String get chooseFromLibrary;

  /// No description provided for @skipPhoto.
  ///
  /// In en, this message translates to:
  /// **'Skip photo'**
  String get skipPhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @cameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Tap to open the camera, or choose from your library.'**
  String get cameraUnavailable;

  /// No description provided for @flashOn.
  ///
  /// In en, this message translates to:
  /// **'Turn flash on'**
  String get flashOn;

  /// No description provided for @flashOff.
  ///
  /// In en, this message translates to:
  /// **'Turn flash off'**
  String get flashOff;

  /// No description provided for @switchCamera.
  ///
  /// In en, this message translates to:
  /// **'Switch camera'**
  String get switchCamera;

  /// No description provided for @addDetails.
  ///
  /// In en, this message translates to:
  /// **'Add details'**
  String get addDetails;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @retakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take again'**
  String get retakePhoto;

  /// No description provided for @keypadClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get keypadClear;

  /// No description provided for @keypadBackspace.
  ///
  /// In en, this message translates to:
  /// **'Delete last digit'**
  String get keypadBackspace;

  /// No description provided for @chooseCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose category'**
  String get chooseCategory;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInTitle;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUpTitle;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your data is saved to your account and private to you.'**
  String get signInSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @signInAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInAction;

  /// No description provided for @signUpAction.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUpAction;

  /// No description provided for @switchToSignUp.
  ///
  /// In en, this message translates to:
  /// **'No account yet? Create one'**
  String get switchToSignUp;

  /// No description provided for @switchToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get switchToSignIn;

  /// No description provided for @errorEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get errorEmailInvalid;

  /// No description provided for @errorPasswordShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least 6 characters'**
  String get errorPasswordShort;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Wrong email or password'**
  String get authInvalidCredentials;

  /// No description provided for @authEmailNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirm your email first, then sign in.'**
  String get authEmailNotConfirmed;

  /// No description provided for @authUserExists.
  ///
  /// In en, this message translates to:
  /// **'This email already has an account. Sign in instead.'**
  String get authUserExists;

  /// No description provided for @authWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Choose a stronger password'**
  String get authWeakPassword;

  /// No description provided for @authNetwork.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the server. Check your connection.'**
  String get authNetwork;

  /// No description provided for @authUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get authUnknown;

  /// No description provided for @confirmEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Check your email to confirm your account, then sign in.'**
  String get confirmEmailSent;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {email}'**
  String signedInAs(String email);

  /// No description provided for @loadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your data'**
  String get loadErrorTitle;

  /// No description provided for @loadErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get loadErrorMessage;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save. Your entry is kept; try again.'**
  String get saveFailed;

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete. Try again.'**
  String get deleteFailed;

  /// No description provided for @errorInsufficientBalance.
  ///
  /// In en, this message translates to:
  /// **'Not enough money in this account'**
  String get errorInsufficientBalance;

  /// No description provided for @noAccountsTitle.
  ///
  /// In en, this message translates to:
  /// **'No accounts yet'**
  String get noAccountsTitle;

  /// No description provided for @dataCloudNote.
  ///
  /// In en, this message translates to:
  /// **'Your data is stored in your Supabase account. Only you can see it.'**
  String get dataCloudNote;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @manageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage categories'**
  String get manageCategories;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// No description provided for @builtInBadge.
  ///
  /// In en, this message translates to:
  /// **'Built-in'**
  String get builtInBadge;

  /// No description provided for @archivedSection.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archivedSection;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategory;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get editCategory;

  /// No description provided for @categoryNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryNameLabel;

  /// No description provided for @iconLabel.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get iconLabel;

  /// No description provided for @colorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorLabel;

  /// No description provided for @archiveAction.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archiveAction;

  /// No description provided for @restoreAction.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restoreAction;

  /// No description provided for @categoryInUseMessage.
  ///
  /// In en, this message translates to:
  /// **'Transactions use this category, so it can\'t be deleted. Archive it to hide it from new transactions.'**
  String get categoryInUseMessage;

  /// No description provided for @deleteCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this category?'**
  String get deleteCategoryTitle;

  /// No description provided for @builtInReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Built-in categories can\'t be changed.'**
  String get builtInReadOnly;

  /// No description provided for @errorNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get errorNameRequired;

  /// No description provided for @errorNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'This name is too long'**
  String get errorNameTooLong;

  /// No description provided for @errorNameDuplicate.
  ///
  /// In en, this message translates to:
  /// **'This name is already used'**
  String get errorNameDuplicate;

  /// No description provided for @addAccount.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get addAccount;

  /// No description provided for @editAccount.
  ///
  /// In en, this message translates to:
  /// **'Edit account'**
  String get editAccount;

  /// No description provided for @accountNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Account name'**
  String get accountNameLabel;

  /// No description provided for @accountNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Cash wallet'**
  String get accountNameHint;

  /// No description provided for @accountTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get accountTypeLabel;

  /// No description provided for @openingBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Opening balance'**
  String get openingBalanceLabel;

  /// No description provided for @openingBalanceHelp.
  ///
  /// In en, this message translates to:
  /// **'Money already in this account. It isn\'t counted as income.'**
  String get openingBalanceHelp;

  /// No description provided for @openingBalanceLocked.
  ///
  /// In en, this message translates to:
  /// **'The opening balance can\'t change once the account has transactions.'**
  String get openingBalanceLocked;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this account?'**
  String get deleteAccountTitle;

  /// No description provided for @accountInUseMessage.
  ///
  /// In en, this message translates to:
  /// **'This account has transactions, so it can\'t be deleted. Delete those transactions first.'**
  String get accountInUseMessage;

  /// No description provided for @currentBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Current balance'**
  String get currentBalanceLabel;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent transactions'**
  String get recentTransactions;

  /// No description provided for @noAccountsMessage.
  ///
  /// In en, this message translates to:
  /// **'Create a wallet or bank account to start recording money.'**
  String get noAccountsMessage;

  /// No description provided for @savedMessage.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedMessage;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// No description provided for @filterTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get filterTime;

  /// No description provided for @periodAnyTime.
  ///
  /// In en, this message translates to:
  /// **'Any time'**
  String get periodAnyTime;

  /// No description provided for @periodThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get periodThisMonth;

  /// No description provided for @periodLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get periodLastMonth;

  /// No description provided for @periodCustom.
  ///
  /// In en, this message translates to:
  /// **'Choose dates…'**
  String get periodCustom;

  /// No description provided for @allAccounts.
  ///
  /// In en, this message translates to:
  /// **'All accounts'**
  String get allAccounts;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategories;

  /// No description provided for @resetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset filters'**
  String get resetFilters;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'{start} – {end}'**
  String dateRange(String start, String end);

  /// No description provided for @resultCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 transaction} other{{count} transactions}}'**
  String resultCount(int count);

  /// No description provided for @customizeGrid.
  ///
  /// In en, this message translates to:
  /// **'Customize calendar'**
  String get customizeGrid;

  /// No description provided for @gridShape.
  ///
  /// In en, this message translates to:
  /// **'Shape'**
  String get gridShape;

  /// No description provided for @shapeRounded.
  ///
  /// In en, this message translates to:
  /// **'Rounded'**
  String get shapeRounded;

  /// No description provided for @shapeCircle.
  ///
  /// In en, this message translates to:
  /// **'Circle'**
  String get shapeCircle;

  /// No description provided for @shapeSquare.
  ///
  /// In en, this message translates to:
  /// **'Square'**
  String get shapeSquare;

  /// No description provided for @gridDisplay.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get gridDisplay;

  /// No description provided for @displaySingle.
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get displaySingle;

  /// No description provided for @displayStacked.
  ///
  /// In en, this message translates to:
  /// **'Stacked'**
  String get displayStacked;

  /// No description provided for @displayFan.
  ///
  /// In en, this message translates to:
  /// **'Fan'**
  String get displayFan;

  /// No description provided for @gridBorder.
  ///
  /// In en, this message translates to:
  /// **'Border'**
  String get gridBorder;

  /// No description provided for @borderAccent.
  ///
  /// In en, this message translates to:
  /// **'Accent'**
  String get borderAccent;

  /// No description provided for @borderNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get borderNone;

  /// No description provided for @borderThin.
  ///
  /// In en, this message translates to:
  /// **'Thin'**
  String get borderThin;

  /// No description provided for @borderColor.
  ///
  /// In en, this message translates to:
  /// **'Border color'**
  String get borderColor;

  /// No description provided for @colorAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get colorAuto;

  /// No description provided for @badgeSection.
  ///
  /// In en, this message translates to:
  /// **'Badge'**
  String get badgeSection;

  /// No description provided for @showCountBadge.
  ///
  /// In en, this message translates to:
  /// **'Show count badge'**
  String get showCountBadge;

  /// No description provided for @monthStartDay.
  ///
  /// In en, this message translates to:
  /// **'Month start day'**
  String get monthStartDay;

  /// No description provided for @monthStartDayHelp.
  ///
  /// In en, this message translates to:
  /// **'Each monthly period starts on this day, for example your payday (default: 1st).'**
  String get monthStartDayHelp;

  /// No description provided for @saveAndAddNext.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get saveAndAddNext;

  /// No description provided for @chooseDay.
  ///
  /// In en, this message translates to:
  /// **'Select day'**
  String get chooseDay;

  /// No description provided for @noteShort.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get noteShort;

  /// No description provided for @bulkEntry.
  ///
  /// In en, this message translates to:
  /// **'Bulk entry'**
  String get bulkEntry;

  /// No description provided for @bulkHint.
  ///
  /// In en, this message translates to:
  /// **'One transaction per line, e.g.\ncoffee 35k\ngrab 52k\nlunch 1tr2\n+salary 15tr'**
  String get bulkHint;

  /// No description provided for @paste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get paste;

  /// No description provided for @bulkEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'As quick as jotting a note'**
  String get bulkEmptyTitle;

  /// No description provided for @bulkEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Type or paste your spending list. The app picks out the amounts and guesses the categories.'**
  String get bulkEmptyBody;

  /// No description provided for @bulkNoAmount.
  ///
  /// In en, this message translates to:
  /// **'No amount found'**
  String get bulkNoAmount;

  /// No description provided for @bulkSave.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing to save yet} =1{Save 1 transaction} other{Save {count} transactions}}'**
  String bulkSave(int count);

  /// No description provided for @bulkSaved.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Added 1 transaction} other{Added {count} transactions}}'**
  String bulkSaved(int count);

  /// No description provided for @layoutGrid.
  ///
  /// In en, this message translates to:
  /// **'Photo grid'**
  String get layoutGrid;

  /// No description provided for @layoutList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get layoutList;

  /// No description provided for @layoutCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get layoutCalendar;

  /// No description provided for @layoutChart.
  ///
  /// In en, this message translates to:
  /// **'Chart'**
  String get layoutChart;

  /// No description provided for @switchLayout.
  ///
  /// In en, this message translates to:
  /// **'Change layout: {current}'**
  String switchLayout(String current);

  /// No description provided for @expenseShort.
  ///
  /// In en, this message translates to:
  /// **'Exp'**
  String get expenseShort;

  /// No description provided for @incomeShort.
  ///
  /// In en, this message translates to:
  /// **'Inc'**
  String get incomeShort;

  /// No description provided for @dailySpending.
  ///
  /// In en, this message translates to:
  /// **'Spending by day'**
  String get dailySpending;

  /// No description provided for @addNotePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Add a note…'**
  String get addNotePlaceholder;

  /// No description provided for @editDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit details'**
  String get editDetails;

  /// No description provided for @moreActions.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get moreActions;

  /// No description provided for @viewerPosition.
  ///
  /// In en, this message translates to:
  /// **'{index} / {count}'**
  String viewerPosition(int index, int count);

  /// No description provided for @dateAtTime.
  ///
  /// In en, this message translates to:
  /// **'{date} at {time}'**
  String dateAtTime(String date, String time);

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @periodThisYear.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get periodThisYear;

  /// No description provided for @periodAllTimeShort.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get periodAllTimeShort;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total balance'**
  String get totalBalance;

  /// No description provided for @accountsSection.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accountsSection;

  /// No description provided for @cashAndBank.
  ///
  /// In en, this message translates to:
  /// **'Cash & bank'**
  String get cashAndBank;

  /// No description provided for @transferMoney.
  ///
  /// In en, this message translates to:
  /// **'Transfer between accounts'**
  String get transferMoney;

  /// No description provided for @termDeposits.
  ///
  /// In en, this message translates to:
  /// **'Term deposits'**
  String get termDeposits;

  /// No description provided for @addDeposit.
  ///
  /// In en, this message translates to:
  /// **'Add deposit'**
  String get addDeposit;

  /// No description provided for @noDepositsTitle.
  ///
  /// In en, this message translates to:
  /// **'No deposits yet'**
  String get noDepositsTitle;

  /// No description provided for @noDepositsMessage.
  ///
  /// In en, this message translates to:
  /// **'Track a bank term deposit to see interest accrue toward maturity.'**
  String get noDepositsMessage;

  /// No description provided for @depositBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get depositBank;

  /// No description provided for @depositBankHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Vietcombank'**
  String get depositBankHint;

  /// No description provided for @depositPrincipal.
  ///
  /// In en, this message translates to:
  /// **'Amount deposited'**
  String get depositPrincipal;

  /// No description provided for @depositRate.
  ///
  /// In en, this message translates to:
  /// **'Rate (%/year)'**
  String get depositRate;

  /// No description provided for @depositTerm.
  ///
  /// In en, this message translates to:
  /// **'Term'**
  String get depositTerm;

  /// No description provided for @depositTermMonths.
  ///
  /// In en, this message translates to:
  /// **'{months, plural, =1{1 month} other{{months} months}}'**
  String depositTermMonths(int months);

  /// No description provided for @depositStart.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get depositStart;

  /// No description provided for @depositMaturity.
  ///
  /// In en, this message translates to:
  /// **'Matures {date}'**
  String depositMaturity(String date);

  /// No description provided for @depositInterestSoFar.
  ///
  /// In en, this message translates to:
  /// **'Interest so far'**
  String get depositInterestSoFar;

  /// No description provided for @depositInterestTotal.
  ///
  /// In en, this message translates to:
  /// **'Interest at maturity'**
  String get depositInterestTotal;

  /// No description provided for @depositMatured.
  ///
  /// In en, this message translates to:
  /// **'Matured'**
  String get depositMatured;

  /// No description provided for @editDeposit.
  ///
  /// In en, this message translates to:
  /// **'Edit deposit'**
  String get editDeposit;

  /// No description provided for @deleteDepositTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this deposit?'**
  String get deleteDepositTitle;

  /// No description provided for @errorBankRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the bank name'**
  String get errorBankRequired;

  /// No description provided for @errorRateInvalid.
  ///
  /// In en, this message translates to:
  /// **'Rate must be 0–100%'**
  String get errorRateInvalid;

  /// No description provided for @depositsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load deposits. Pull down to retry.'**
  String get depositsLoadFailed;

  /// No description provided for @depositRateTerm.
  ///
  /// In en, this message translates to:
  /// **'{rate}%/year · {months} mo'**
  String depositRateTerm(String rate, int months);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
