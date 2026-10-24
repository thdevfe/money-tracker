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
}
