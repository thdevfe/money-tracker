// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Sổ Thu Chi';

  @override
  String get navHome => 'Tổng quan';

  @override
  String get navTransactions => 'Giao dịch';

  @override
  String get navAdd => 'Thêm giao dịch';

  @override
  String get navReports => 'Báo cáo';

  @override
  String get navAccounts => 'Tài khoản';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get previousMonth => 'Tháng trước';

  @override
  String get nextMonth => 'Tháng sau';

  @override
  String get goToToday => 'Hôm nay';

  @override
  String get today => 'Hôm nay';

  @override
  String get yesterday => 'Hôm qua';

  @override
  String get summaryBalance => 'Tổng số dư';

  @override
  String get summaryIncome => 'Thu nhập';

  @override
  String get summaryExpense => 'Chi tiêu';

  @override
  String summaryMonthCaption(String month) {
    return 'Trong $month';
  }

  @override
  String get calendarLegendExpense => 'Chi tiêu theo ngày';

  @override
  String get calendarLegendIncome => 'Thu nhập';

  @override
  String calendarDaySemantics(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giao dịch',
      zero: 'Không có giao dịch',
    );
    return '$date. $_temp0';
  }

  @override
  String get calendarSelected => 'Đang chọn';

  @override
  String morePhotosSemantics(int count) {
    return 'Thêm $count ảnh';
  }

  @override
  String compactThousands(String value) {
    return '${value}k';
  }

  @override
  String compactMillions(String value) {
    return '${value}tr';
  }

  @override
  String compactBillions(String value) {
    return '${value}tỷ';
  }

  @override
  String expenseAmountSemantics(String amount) {
    return 'Chi tiêu $amount';
  }

  @override
  String incomeAmountSemantics(String amount) {
    return 'Thu nhập $amount';
  }

  @override
  String transferAmountSemantics(String amount) {
    return 'Chuyển khoản $amount';
  }

  @override
  String get dayExpenseLabel => 'Đã chi';

  @override
  String get dayIncomeLabel => 'Đã thu';

  @override
  String get viewAll => 'Xem tất cả';

  @override
  String moreTransactions(int count) {
    return '+$count giao dịch khác';
  }

  @override
  String get dayEmptyTitle => 'Chưa ghi nhận gì';

  @override
  String get dayEmptyMessage => 'Thêm khoản chi hoặc khoản thu cho ngày này.';

  @override
  String get monthEmptyTitle => 'Tháng này chưa có giao dịch';

  @override
  String get monthEmptyMessage =>
      'Nhấn + để ghi một khoản chi hoặc thu. Ảnh là tùy chọn.';

  @override
  String get addTransaction => 'Thêm giao dịch';

  @override
  String get filterAll => 'Tất cả';

  @override
  String get typeExpense => 'Khoản chi';

  @override
  String get typeIncome => 'Khoản thu';

  @override
  String get typeTransfer => 'Chuyển khoản';

  @override
  String get filterEmptyTitle => 'Không có giao dịch phù hợp';

  @override
  String get filterEmptyMessage => 'Hãy thử bộ lọc hoặc từ khóa khác.';

  @override
  String get showAll => 'Hiện tất cả';

  @override
  String get transactionsEmptyTitle => 'Chưa có giao dịch';

  @override
  String get transactionsEmptyMessage =>
      'Các khoản chi, thu và chuyển khoản sẽ hiển thị ở đây.';

  @override
  String get search => 'Tìm kiếm';

  @override
  String get closeSearch => 'Đóng tìm kiếm';

  @override
  String get searchHint => 'Tìm theo ghi chú hoặc danh mục';

  @override
  String transferRoute(String from, String to) {
    return '$from → $to';
  }

  @override
  String get addTitle => 'Giao dịch mới';

  @override
  String get editTitle => 'Sửa giao dịch';

  @override
  String get cancel => 'Hủy';

  @override
  String get save => 'Lưu';

  @override
  String get amountLabel => 'Số tiền';

  @override
  String get categoryLabel => 'Danh mục';

  @override
  String get accountLabel => 'Tài khoản';

  @override
  String get fromAccountLabel => 'Từ tài khoản';

  @override
  String get toAccountLabel => 'Đến tài khoản';

  @override
  String get dateLabel => 'Ngày';

  @override
  String get timeLabel => 'Giờ';

  @override
  String get noteLabel => 'Ghi chú (không bắt buộc)';

  @override
  String get noteHint => 'VD: Ăn trưa với đồng nghiệp';

  @override
  String get photoLabel => 'Ảnh (không bắt buộc)';

  @override
  String get photoHelp => 'Bạn có thể lưu mà không cần ảnh.';

  @override
  String get photoCamera => 'Chụp ảnh';

  @override
  String get photoLibrary => 'Thư viện';

  @override
  String get photoReplace => 'Đổi ảnh';

  @override
  String get photoRemove => 'Gỡ ảnh';

  @override
  String get photoPreviewSemantics => 'Ảnh đính kèm';

  @override
  String get photoPickError =>
      'Không mở được ảnh. Bạn vẫn có thể lưu mà không cần ảnh.';

  @override
  String get typeLockedHint => 'Không thể đổi loại khi đang sửa.';

  @override
  String get errorAmountRequired => 'Nhập số tiền';

  @override
  String get errorAmountPositive => 'Số tiền phải lớn hơn 0';

  @override
  String get errorAmountTooLarge => 'Số tiền quá lớn';

  @override
  String get errorCategoryRequired => 'Chọn danh mục';

  @override
  String get errorSameAccount => 'Chọn hai tài khoản khác nhau';

  @override
  String get savedAdded => 'Đã thêm giao dịch';

  @override
  String get savedUpdated => 'Đã lưu thay đổi';

  @override
  String get deleted => 'Đã xóa giao dịch';

  @override
  String get delete => 'Xóa';

  @override
  String get deleteConfirmTitle => 'Xóa giao dịch này?';

  @override
  String get deleteConfirmMessage => 'Thao tác này không thể hoàn tác.';

  @override
  String get discardTitle => 'Bỏ các thay đổi?';

  @override
  String get discardMessage => 'Những thay đổi chưa lưu sẽ bị mất.';

  @override
  String get discard => 'Bỏ thay đổi';

  @override
  String get keepEditing => 'Tiếp tục sửa';

  @override
  String get catFood => 'Ăn uống';

  @override
  String get catTransport => 'Di chuyển';

  @override
  String get catShopping => 'Mua sắm';

  @override
  String get catBills => 'Hóa đơn';

  @override
  String get catHousing => 'Nhà ở';

  @override
  String get catHealth => 'Sức khỏe';

  @override
  String get catEntertainment => 'Giải trí';

  @override
  String get catEducation => 'Giáo dục';

  @override
  String get catTravel => 'Du lịch';

  @override
  String get catPersonalCare => 'Làm đẹp';

  @override
  String get catOtherExpense => 'Khác';

  @override
  String get catSalary => 'Lương';

  @override
  String get catFreelance => 'Làm tự do';

  @override
  String get catBusiness => 'Kinh doanh';

  @override
  String get catInvestment => 'Đầu tư';

  @override
  String get catGift => 'Quà tặng';

  @override
  String get catOtherIncome => 'Thu khác';

  @override
  String get accountTypeCash => 'Tiền mặt';

  @override
  String get accountTypeBank => 'Ngân hàng';

  @override
  String get accountsTotalLabel => 'Tổng số dư các tài khoản';

  @override
  String get accountsLaterNote => 'Tạo và sửa tài khoản sẽ có ở giai đoạn sau.';

  @override
  String get reportsComingTitle => 'Báo cáo sẽ sớm có';

  @override
  String get reportsComingMessage =>
      'Chi tiêu theo danh mục sẽ hiển thị ở đây trong giai đoạn sau.';

  @override
  String get settingsAppearance => 'Giao diện';

  @override
  String get themeSystem => 'Hệ thống';

  @override
  String get themeLight => 'Sáng';

  @override
  String get themeDark => 'Tối';

  @override
  String get settingsLanguage => 'Ngôn ngữ';

  @override
  String get languageSystem => 'Hệ thống';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsCurrency => 'Tiền tệ';

  @override
  String get currencyVnd => 'Đồng Việt Nam (VND)';

  @override
  String get settingsData => 'Dữ liệu';

  @override
  String get dataPrototypeNote =>
      'Bản thử nghiệm: dữ liệu mẫu chỉ nằm trong bộ nhớ và được đặt lại khi khởi động lại ứng dụng. Không có dữ liệu nào rời khỏi thiết bị.';

  @override
  String get greetingMorning => 'Chào buổi sáng';

  @override
  String get greetingAfternoon => 'Chào buổi chiều';

  @override
  String get greetingEvening => 'Chào buổi tối';

  @override
  String get defaultUserName => 'Bạn';

  @override
  String spentToday(String amount) {
    return 'Hôm nay đã chi $amount';
  }

  @override
  String get viewDay => 'Ngày';

  @override
  String get viewMonth => 'Tháng';

  @override
  String get hideAmounts => 'Ẩn số tiền';

  @override
  String get showAmounts => 'Hiện số tiền';

  @override
  String get chooseMonth => 'Chọn tháng';

  @override
  String get previousYear => 'Năm trước';

  @override
  String get nextYear => 'Năm sau';

  @override
  String get previousDay => 'Ngày trước';

  @override
  String get nextDay => 'Ngày sau';

  @override
  String get navProfile => 'Hồ sơ';

  @override
  String get profileName => 'Tên của bạn';

  @override
  String get openProfile => 'Mở hồ sơ';

  @override
  String moreItemsSemantics(int count) {
    return 'Thêm $count giao dịch';
  }

  @override
  String get periodMonth => 'Tháng';

  @override
  String get periodYear => 'Năm';

  @override
  String get periodAllTime => 'Tất cả';

  @override
  String get allTimeTitle => 'Toàn thời gian';

  @override
  String get reportsBalance => 'Còn lại';

  @override
  String get savingsRate => 'Tỷ lệ tiết kiệm';

  @override
  String get tabCluster => 'Cụm';

  @override
  String get tabMap => 'Bản đồ';

  @override
  String get laterVersionTitle => 'Sẽ có ở phiên bản sau';

  @override
  String get laterVersionMessage =>
      'Chế độ xem này sẽ được làm sau khi hoàn thành các tính năng chính.';

  @override
  String get reportsNoExpenses => 'Không có khoản chi trong kỳ này';

  @override
  String categoryShareDetail(int count, String percent) {
    return '$count giao dịch · $percent';
  }

  @override
  String get photoUpload => 'Tải ảnh lên';

  @override
  String get photoQuickHint => 'Chụp hóa đơn hoặc khoảnh khắc. Không bắt buộc.';

  @override
  String get detailsLabel => 'Chi tiết';

  @override
  String get typeShortExpense => 'Chi';

  @override
  String get typeShortIncome => 'Thu';

  @override
  String get typeShortTransfer => 'Chuyển';

  @override
  String get chooseFromLibrary => 'Chọn từ thư viện';

  @override
  String get skipPhoto => 'Bỏ qua ảnh';

  @override
  String get takePhoto => 'Chụp ảnh';

  @override
  String get cameraUnavailable =>
      'Nhấn để mở máy ảnh, hoặc chọn ảnh từ thư viện.';

  @override
  String get flashOn => 'Bật đèn flash';

  @override
  String get flashOff => 'Tắt đèn flash';

  @override
  String get switchCamera => 'Đổi máy ảnh';

  @override
  String get addDetails => 'Thêm chi tiết';

  @override
  String get done => 'Xong';

  @override
  String get changePhoto => 'Đổi ảnh';

  @override
  String get retakePhoto => 'Chụp lại';

  @override
  String get keypadClear => 'Xóa hết';

  @override
  String get keypadBackspace => 'Xóa số cuối';

  @override
  String get chooseCategory => 'Chọn danh mục';

  @override
  String get signInTitle => 'Đăng nhập';

  @override
  String get signUpTitle => 'Tạo tài khoản';

  @override
  String get signInSubtitle =>
      'Dữ liệu được lưu vào tài khoản của bạn và chỉ bạn xem được.';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Mật khẩu';

  @override
  String get signInAction => 'Đăng nhập';

  @override
  String get signUpAction => 'Tạo tài khoản';

  @override
  String get switchToSignUp => 'Chưa có tài khoản? Tạo mới';

  @override
  String get switchToSignIn => 'Đã có tài khoản? Đăng nhập';

  @override
  String get errorEmailInvalid => 'Nhập email hợp lệ';

  @override
  String get errorPasswordShort => 'Dùng ít nhất 6 ký tự';

  @override
  String get authInvalidCredentials => 'Sai email hoặc mật khẩu';

  @override
  String get authEmailNotConfirmed =>
      'Hãy xác nhận email trước, rồi đăng nhập.';

  @override
  String get authUserExists => 'Email này đã có tài khoản. Hãy đăng nhập.';

  @override
  String get authWeakPassword => 'Hãy chọn mật khẩu mạnh hơn';

  @override
  String get authNetwork =>
      'Không kết nối được máy chủ. Kiểm tra mạng của bạn.';

  @override
  String get authUnknown => 'Đã có lỗi. Hãy thử lại.';

  @override
  String get confirmEmailSent =>
      'Hãy mở email để xác nhận tài khoản, rồi đăng nhập.';

  @override
  String get signOut => 'Đăng xuất';

  @override
  String signedInAs(String email) {
    return 'Đang đăng nhập: $email';
  }

  @override
  String get loadErrorTitle => 'Không tải được dữ liệu';

  @override
  String get loadErrorMessage => 'Kiểm tra kết nối mạng rồi thử lại.';

  @override
  String get retry => 'Thử lại';

  @override
  String get saveFailed =>
      'Không lưu được. Thông tin vẫn được giữ, hãy thử lại.';

  @override
  String get deleteFailed => 'Không xóa được. Hãy thử lại.';

  @override
  String get errorInsufficientBalance => 'Tài khoản không đủ tiền';

  @override
  String get noAccountsTitle => 'Chưa có tài khoản tiền';

  @override
  String get dataCloudNote =>
      'Dữ liệu được lưu trên tài khoản Supabase của bạn. Chỉ bạn xem được.';

  @override
  String get showPassword => 'Hiện mật khẩu';

  @override
  String get hidePassword => 'Ẩn mật khẩu';

  @override
  String get manageCategories => 'Quản lý danh mục';

  @override
  String get categoriesTitle => 'Danh mục';

  @override
  String get builtInBadge => 'Mặc định';

  @override
  String get archivedSection => 'Đã lưu trữ';

  @override
  String get addCategory => 'Thêm danh mục';

  @override
  String get editCategory => 'Sửa danh mục';

  @override
  String get categoryNameLabel => 'Tên danh mục';

  @override
  String get iconLabel => 'Biểu tượng';

  @override
  String get colorLabel => 'Màu';

  @override
  String get archiveAction => 'Lưu trữ';

  @override
  String get restoreAction => 'Khôi phục';

  @override
  String get categoryInUseMessage =>
      'Danh mục đang được dùng nên không thể xóa. Hãy lưu trữ để ẩn khỏi giao dịch mới.';

  @override
  String get deleteCategoryTitle => 'Xóa danh mục này?';

  @override
  String get builtInReadOnly => 'Không thể sửa danh mục mặc định.';

  @override
  String get errorNameRequired => 'Nhập tên';

  @override
  String get errorNameTooLong => 'Tên quá dài';

  @override
  String get errorNameDuplicate => 'Tên này đã được dùng';

  @override
  String get addAccount => 'Thêm tài khoản';

  @override
  String get editAccount => 'Sửa tài khoản';

  @override
  String get accountNameLabel => 'Tên tài khoản';

  @override
  String get accountNameHint => 'VD: Ví tiền mặt';

  @override
  String get accountTypeLabel => 'Loại';

  @override
  String get openingBalanceLabel => 'Số dư ban đầu';

  @override
  String get openingBalanceHelp =>
      'Số tiền đang có sẵn. Không tính là thu nhập.';

  @override
  String get openingBalanceLocked =>
      'Không thể sửa số dư ban đầu khi tài khoản đã có giao dịch.';

  @override
  String get deleteAccountTitle => 'Xóa tài khoản này?';

  @override
  String get accountInUseMessage =>
      'Tài khoản đang có giao dịch nên không thể xóa. Hãy xóa các giao dịch đó trước.';

  @override
  String get currentBalanceLabel => 'Số dư hiện tại';

  @override
  String get recentTransactions => 'Giao dịch gần đây';

  @override
  String get noAccountsMessage =>
      'Hãy tạo ví hoặc tài khoản ngân hàng để bắt đầu ghi chép.';

  @override
  String get savedMessage => 'Đã lưu';

  @override
  String get noTransactionsYet => 'Chưa có giao dịch';

  @override
  String get filterTime => 'Thời gian';

  @override
  String get periodAnyTime => 'Mọi lúc';

  @override
  String get periodThisMonth => 'Tháng này';

  @override
  String get periodLastMonth => 'Tháng trước';

  @override
  String get periodCustom => 'Chọn khoảng ngày…';

  @override
  String get allAccounts => 'Tất cả tài khoản';

  @override
  String get allCategories => 'Tất cả danh mục';

  @override
  String get resetFilters => 'Xóa bộ lọc';

  @override
  String dateRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String resultCount(int count) {
    return '$count giao dịch';
  }

  @override
  String get customizeGrid => 'Tùy chỉnh lịch';

  @override
  String get gridShape => 'Hình dạng';

  @override
  String get shapeRounded => 'Bo góc';

  @override
  String get shapeCircle => 'Tròn';

  @override
  String get shapeSquare => 'Vuông';

  @override
  String get gridDisplay => 'Hiển thị';

  @override
  String get displaySingle => 'Một ảnh';

  @override
  String get displayStacked => 'Xếp chồng';

  @override
  String get displayFan => 'Xòe quạt';

  @override
  String get gridBorder => 'Viền';

  @override
  String get borderAccent => 'Nổi bật';

  @override
  String get borderNone => 'Không viền';

  @override
  String get borderThin => 'Mảnh';

  @override
  String get borderColor => 'Màu viền';

  @override
  String get colorAuto => 'Tự động';

  @override
  String get badgeSection => 'Huy hiệu';

  @override
  String get showCountBadge => 'Hiện số giao dịch thêm';

  @override
  String get monthStartDay => 'Ngày bắt đầu tháng';

  @override
  String get monthStartDayHelp =>
      'Mỗi kỳ tháng bắt đầu từ ngày này, ví dụ ngày nhận lương (mặc định: ngày 1).';

  @override
  String get saveAndAddNext => 'Thêm';

  @override
  String get chooseDay => 'Chọn ngày';

  @override
  String get noteShort => 'Ghi chú';

  @override
  String get bulkEntry => 'Nhập nhiều khoản';

  @override
  String get bulkHint =>
      'Mỗi dòng một giao dịch, ví dụ:\ncà phê 35k\ngrab 52k\năn trưa 1tr2\n+lương 15tr';

  @override
  String get paste => 'Dán';

  @override
  String get bulkEmptyTitle => 'Nhanh như ghi chú';

  @override
  String get bulkEmptyBody =>
      'Gõ hoặc dán danh sách chi tiêu. App tự nhận số tiền và đoán danh mục.';

  @override
  String get bulkNoAmount => 'Không thấy số tiền';

  @override
  String bulkSave(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Lưu $count giao dịch',
      zero: 'Chưa có khoản nào',
    );
    return '$_temp0';
  }

  @override
  String bulkSaved(int count) {
    return 'Đã thêm $count giao dịch';
  }

  @override
  String get layoutGrid => 'Lưới ảnh';

  @override
  String get layoutList => 'Danh sách';

  @override
  String get layoutCalendar => 'Lịch';

  @override
  String get layoutChart => 'Biểu đồ';

  @override
  String switchLayout(String current) {
    return 'Đổi kiểu hiển thị: $current';
  }

  @override
  String get expenseShort => 'Chi';

  @override
  String get incomeShort => 'Thu';

  @override
  String get dailySpending => 'Chi tiêu theo ngày';

  @override
  String get addNotePlaceholder => 'Thêm ghi chú…';

  @override
  String get editDetails => 'Sửa chi tiết';

  @override
  String get moreActions => 'Thêm thao tác';

  @override
  String viewerPosition(int index, int count) {
    return '$index / $count';
  }

  @override
  String dateAtTime(String date, String time) {
    return '$date lúc $time';
  }

  @override
  String get close => 'Đóng';

  @override
  String get periodThisYear => 'Năm nay';

  @override
  String get periodAllTimeShort => 'Tất cả';

  @override
  String get totalBalance => 'Tổng số dư';

  @override
  String get accountsSection => 'Tài khoản';

  @override
  String get cashAndBank => 'Tiền mặt & ngân hàng';

  @override
  String get transferMoney => 'Chuyển tiền giữa tài khoản';

  @override
  String get termDeposits => 'Tiền gửi có kỳ hạn';

  @override
  String get addDeposit => 'Thêm khoản gửi';

  @override
  String get noDepositsTitle => 'Chưa có khoản gửi nào';

  @override
  String get noDepositsMessage =>
      'Theo dõi tiền gửi có kỳ hạn để xem tiền lãi tăng dần đến ngày đáo hạn.';

  @override
  String get depositBank => 'Ngân hàng';

  @override
  String get depositBankHint => 'VD: Vietcombank';

  @override
  String get depositPrincipal => 'Số tiền gửi';

  @override
  String get depositRate => 'Lãi suất (%/năm)';

  @override
  String get depositTerm => 'Kỳ hạn';

  @override
  String depositTermMonths(int months) {
    return '$months tháng';
  }

  @override
  String get depositStart => 'Ngày gửi';

  @override
  String depositMaturity(String date) {
    return 'Đáo hạn $date';
  }

  @override
  String get depositInterestSoFar => 'Lãi đến nay';

  @override
  String get depositInterestTotal => 'Lãi khi đáo hạn';

  @override
  String get depositMatured => 'Đã đáo hạn';

  @override
  String get editDeposit => 'Sửa khoản gửi';

  @override
  String get deleteDepositTitle => 'Xóa khoản gửi này?';

  @override
  String get errorBankRequired => 'Nhập tên ngân hàng';

  @override
  String get errorRateInvalid => 'Lãi suất từ 0 đến 100%';

  @override
  String get depositsLoadFailed =>
      'Không tải được tiền gửi. Kéo xuống để thử lại.';

  @override
  String depositRateTerm(String rate, int months) {
    return '$rate%/năm · $months tháng';
  }

  @override
  String get navBudgets => 'Ngân sách';

  @override
  String get budgetsTitle => 'Quản lý ngân sách';

  @override
  String get budgetsSubtitle => 'Tạo và theo dõi nhiều ngân sách';

  @override
  String get noBudgetsTitle => 'Chưa có ngân sách';

  @override
  String get noBudgetsMessage => 'Tạo ngân sách để theo dõi chi tiêu';

  @override
  String get startFromTemplate => 'Bắt đầu từ mẫu';

  @override
  String get templateMonthlyTitle => 'Chi tiêu hàng tháng';

  @override
  String get templateMonthlyBody =>
      'Một hạn mức cho mọi khoản chi · Bạn tự đặt số tiền';

  @override
  String get templateTopTitle => 'Danh mục chi nhiều nhất';

  @override
  String templateTopBody(String names) {
    return 'Hạn mức riêng cho $names · Bạn tự đặt số tiền';
  }

  @override
  String get addBudget => 'Tạo ngân sách';

  @override
  String get editBudget => 'Sửa ngân sách';

  @override
  String get budgetName => 'Tên ngân sách';

  @override
  String get budgetLimit => 'Hạn mức mỗi tháng';

  @override
  String get budgetCategories => 'Tính các danh mục';

  @override
  String get budgetAllSpending => 'Mọi khoản chi';

  @override
  String budgetSpentOf(String spent, String limit) {
    return 'Đã chi $spent / $limit';
  }

  @override
  String budgetLeft(String amount) {
    return 'Còn $amount';
  }

  @override
  String budgetOver(String amount) {
    return 'Vượt $amount';
  }

  @override
  String budgetDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Còn $days ngày',
      zero: 'Ngày cuối kỳ',
    );
    return '$_temp0';
  }

  @override
  String get deleteBudgetTitle => 'Xóa ngân sách này?';

  @override
  String get budgetsLoadFailed =>
      'Không tải được ngân sách. Kéo xuống để thử lại.';

  @override
  String memberSince(String date) {
    return 'Thành viên từ $date';
  }

  @override
  String get statTransactions => 'Giao dịch';

  @override
  String get statIncome => 'Tổng thu';

  @override
  String get statExpense => 'Tổng chi';

  @override
  String get sectionTools => 'CÔNG CỤ';

  @override
  String get sectionPreferences => 'TÙY CHỌN';

  @override
  String get sectionAccountData => 'TÀI KHOẢN & DỮ LIỆU';

  @override
  String get editName => 'Đổi tên';
}
