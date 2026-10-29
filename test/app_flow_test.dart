import 'package:expense_tracker/app/app.dart';
import 'package:expense_tracker/features/auth/providers/auth_provider.dart';
import 'package:expense_tracker/features/settings/domain/calendar_grid_settings.dart';
import 'package:expense_tracker/features/settings/presentation/customize_grid_sheet.dart';
import 'package:expense_tracker/features/settings/providers/settings_provider.dart';
import 'package:expense_tracker/features/transactions/data/in_memory_ledger_repository.dart';
import 'package:expense_tracker/features/transactions/data/mock_data.dart';
import 'package:expense_tracker/features/transactions/domain/ledger_repository.dart';
import 'package:expense_tracker/features/transactions/domain/models.dart';
import 'package:expense_tracker/features/transactions/domain/transaction_query.dart';
import 'package:expense_tracker/features/transactions/presentation/form/capture_photo_screen.dart';
import 'package:expense_tracker/features/transactions/presentation/home/widgets/photo_calendar_day_cell.dart';
import 'package:expense_tracker/features/transactions/providers/transactions_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _now = DateTime(2026, 10, 24, 20, 30);

Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: [
      clockProvider.overrideWithValue(() => _now),
      cameraListProvider.overrideWithValue(() async => const []),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MoneyTrackerApp(),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

Finder dayCell(int day) => find.byWidgetPredicate(
  (w) =>
      w is PhotoCalendarDayCell &&
      w.inMonth &&
      w.date == DateTime(2026, 10, day),
);

/// Opens Add, skips the photo step and lands on the entry screen.
Future<void> openAddForm(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Thêm giao dịch'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Bỏ qua ảnh'));
  await tester.pumpAndSettle();
}

/// Taps keypad keys, e.g. `['1', '2', '000']` or `['add']`.
Future<void> typeKeys(WidgetTester tester, List<String> keys) async {
  for (final k in keys) {
    await tester.tap(find.byKey(ValueKey('keypad_$k')));
    await tester.pump();
  }
}

Future<void> tapDone(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('keypad_done')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Home shows the month, summary and photo calendar', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('Tháng 10 năm 2026'), findsOneWidget);
    expect(find.text('Chào buổi tối'), findsOneWidget);
    expect(find.textContaining('Hôm nay đã chi 365.000'), findsOneWidget);
    // Busy day 6 stacks two items and badges the rest (7 transactions).
    expect(
      find.descendant(of: dayCell(6), matching: find.text('+5')),
      findsOneWidget,
    );
    // Single-item days have no badge.
    expect(
      find.descendant(of: dayCell(1), matching: find.textContaining('+')),
      findsNothing,
    );
    // Selected day (today) preview.
    expect(find.text('Hôm nay'), findsOneWidget);
  });

  testWidgets('Selecting a day updates the preview', (tester) async {
    await pumpApp(tester);

    await tester.tap(dayCell(6));
    await tester.pumpAndSettle();

    expect(find.text('Thứ Ba, 6 tháng 10, 2026'), findsOneWidget);
    expect(find.text('Hôm nay'), findsNothing);
  });

  testWidgets('An empty month shows the empty state', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byTooltip('Tháng sau'));
    await tester.pumpAndSettle();

    expect(find.text('Tháng 11 năm 2026'), findsOneWidget);
    expect(find.text('Tháng này chưa có giao dịch'), findsOneWidget);
  });

  testWidgets('Saving an expense without a photo works on one tap', (
    tester,
  ) async {
    final container = await pumpApp(tester);
    final before = container.read(transactionsProvider).length;

    await openAddForm(tester);
    await typeKeys(tester, ['1', '2', '0', '000']);
    expect(find.text('120.000'), findsOneWidget);
    await tapDone(tester);

    expect(find.text('Đã thêm giao dịch'), findsOneWidget);
    final items = container.read(transactionsProvider);
    expect(items.length, before + 1);
    final added = items.firstWhere((t) => t.amountMinor == 120000);
    expect(added.photo, isNull);
    // The first category is preselected for quick entry.
    expect(added.category, const Category.system(CategoryCode.food));
    // Defaults to the day selected on Home.
    expect(added.occurredAt.day, 24);
  });

  testWidgets('Keypad calculates before saving', (tester) async {
    final container = await pumpApp(tester);

    await openAddForm(tester);
    await typeKeys(tester, ['1', '2', '0', '000', 'add', '3', '5', '000']);
    expect(find.textContaining('155.000'), findsOneWidget);
    await tapDone(tester);

    expect(
      container.read(transactionsProvider).any((t) => t.amountMinor == 155000),
      isTrue,
    );
  });

  testWidgets('Form validation blocks empty and zero amounts', (tester) async {
    final container = await pumpApp(tester);
    final before = container.read(transactionsProvider).length;

    await openAddForm(tester);
    await tapDone(tester);
    expect(find.text('Nhập số tiền'), findsOneWidget);

    await typeKeys(tester, ['0']);
    await tapDone(tester);
    expect(find.text('Số tiền phải lớn hơn 0'), findsOneWidget);
    expect(container.read(transactionsProvider).length, before);
  });

  testWidgets('Transfer hides category/photo and rejects the same account', (
    tester,
  ) async {
    await pumpApp(tester);
    await openAddForm(tester);

    await tester.tap(find.byTooltip('Chuyển khoản'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('category')), findsNothing);
    expect(find.text('Chụp ảnh'), findsNothing);

    await typeKeys(tester, ['5', '0', '000']);
    // Change destination to the source account (Vietcombank).
    await tester.tap(find.byKey(const ValueKey('to_account')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vietcombank').last);
    await tester.pumpAndSettle();
    await tapDone(tester);

    expect(find.text('Chọn hai tài khoản khác nhau'), findsOneWidget);
  });

  testWidgets('Leaving with unsaved changes asks for confirmation', (
    tester,
  ) async {
    await pumpApp(tester);
    await openAddForm(tester);

    await typeKeys(tester, ['1']);
    await tester.tap(find.text('Hủy'));
    await tester.pumpAndSettle();
    expect(find.text('Bỏ các thay đổi?'), findsOneWidget);

    await tester.tap(find.text('Bỏ thay đổi'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('keypad_done')), findsNothing);
  });

  testWidgets('Editing opens the existing transaction', (tester) async {
    await pumpApp(tester);

    // Scroll the day preview above the floating nav bar.
    await tester.drag(find.byType(ListView).first, const Offset(0, -600));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mua sắm').first);
    await tester.pumpAndSettle();

    expect(find.byTooltip('Xóa'), findsOneWidget);
    expect(find.text('Không thể đổi loại khi đang sửa.'), findsOneWidget);
    expect(find.text('165.000'), findsOneWidget);
  });

  testWidgets('Transactions tab filters by type and shows no-results state', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.byTooltip('Giao dịch'));
    await tester.pumpAndSettle();
    final transferChip = find.widgetWithText(ChoiceChip, 'Chuyển khoản');
    await tester.ensureVisible(transferChip);
    await tester.pumpAndSettle();
    await tester.tap(transferChip);
    await tester.pumpAndSettle();
    expect(find.text('Rút tiền ATM'), findsWidgets);
    expect(find.text('Cà phê'), findsNothing);

    await tester.tap(find.byTooltip('Tìm kiếm'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('Không có giao dịch phù hợp'), findsOneWidget);

    await tester.tap(find.text('Hiện tất cả'));
    await tester.pumpAndSettle();
    expect(find.text('Cà phê'), findsWidgets);
  });

  testWidgets('Switching language to English updates visible strings', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.byTooltip('Hồ sơ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Home'));
    await tester.pumpAndSettle();

    expect(find.text('October 2026'), findsOneWidget);
    expect(find.text('Good evening'), findsOneWidget);
  });

  testWidgets('Day view shows the selected day as a photo grid', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Ngày'));
    await tester.pumpAndSettle();

    expect(find.byType(PhotoCalendarDayCell), findsNothing);
    expect(find.text('Th 7, 24 thg 10'), findsOneWidget);
    expect(find.textContaining('55.000'), findsWidgets);
  });

  testWidgets('Hide amounts masks money values', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byTooltip('Ẩn số tiền'));
    await tester.pumpAndSettle();

    expect(find.textContaining('365.000'), findsNothing);
    expect(find.textContaining('•••••'), findsWidgets);
  });

  testWidgets('Reports shows totals, savings rate and categories', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.byTooltip('Báo cáo'));
    await tester.pumpAndSettle();

    expect(find.text('Tỷ lệ tiết kiệm'), findsOneWidget);
    expect(find.text('Ăn uống'), findsOneWidget);

    await tester.tap(find.text('Năm'));
    await tester.pumpAndSettle();
    expect(find.text('2026'), findsOneWidget);

    await tester.tap(find.text('Cụm'));
    await tester.pumpAndSettle();
    expect(find.text('Sẽ có ở phiên bản sau'), findsOneWidget);
  });

  testWidgets('Add starts with the capture step, then the entry screen', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.byTooltip('Thêm giao dịch'));
    await tester.pumpAndSettle();
    expect(find.text('Chọn từ thư viện'), findsOneWidget);
    expect(find.text('Bỏ qua ảnh'), findsOneWidget);
    // No camera in tests: the viewfinder explains the system-camera fallback
    // and the shutter stays enabled (it opens the system camera).
    expect(find.textContaining('Nhấn để mở máy ảnh'), findsOneWidget);
    final handle = tester.ensureSemantics();
    expect(
      tester.getSemantics(find.bySemanticsLabel('Chụp ảnh')),
      isSemantics(isButton: true, isEnabled: true),
    );
    handle.dispose();

    await tester.tap(find.text('Bỏ qua ảnh'));
    await tester.pumpAndSettle();
    expect(find.text('Thêm chi tiết'), findsOneWidget);
    expect(find.byKey(const ValueKey('category')), findsOneWidget);

    await tester.tap(find.text('Thêm chi tiết'));
    await tester.pumpAndSettle();
    expect(find.text('Ghi chú (không bắt buộc)'), findsOneWidget);
  });

  testWidgets('Spending more than the wallet holds is blocked', (tester) async {
    final container = await pumpApp(tester);
    final before = container.read(transactionsProvider).length;

    await openAddForm(tester);
    // Far more than the demo cash wallet holds.
    await typeKeys(tester, ['9', '9', '000', '000']);
    await tapDone(tester);

    expect(find.text('Tài khoản không đủ tiền'), findsOneWidget);
    expect(container.read(transactionsProvider).length, before);
  });

  testWidgets('A failed save keeps the form open with the entry', (
    tester,
  ) async {
    final container = await pumpApp(
      tester,
      overrides: [
        ledgerRepositoryProvider.overrideWith(
          (ref) => _FailingSaveRepository(ref.watch(clockProvider)()),
        ),
      ],
    );
    final before = container.read(transactionsProvider).length;

    await openAddForm(tester);
    await typeKeys(tester, ['1', '2', '000']);
    await tapDone(tester);

    expect(
      find.text('Không lưu được. Thông tin vẫn được giữ, hãy thử lại.'),
      findsOneWidget,
    );
    expect(find.text('12.000'), findsOneWidget);
    expect(container.read(transactionsProvider).length, before);
  });

  testWidgets('Signed-out users see the sign-in screen', (tester) async {
    await pumpApp(
      tester,
      overrides: [currentUserIdProvider.overrideWith((ref) => _SignedOut())],
    );

    expect(find.text('Đăng nhập'), findsWidgets);
    expect(find.byType(PhotoCalendarDayCell), findsNothing);
  });

  testWidgets('Creating an account adds it to the Accounts tab', (
    tester,
  ) async {
    final container = await pumpApp(tester);

    await tester.tap(find.byTooltip('Tài khoản'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Thêm tài khoản'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Momo');
    await tester.tap(find.text('Ngân hàng'));
    await tester.enterText(find.byType(TextField).last, '500000');
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();

    expect(find.text('Momo'), findsOneWidget);
    final momo = container
        .read(accountsProvider)
        .firstWhere((a) => a.name == 'Momo');
    expect(momo.type, AccountType.bank);
    expect(momo.openingBalanceMinor, 500000);
  });

  testWidgets('An account with transactions cannot be deleted', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byTooltip('Tài khoản'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ví tiền mặt'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Xóa'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Xóa'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Tài khoản đang có giao dịch'), findsOneWidget);
  });

  testWidgets('A new custom category can be picked when adding', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.byTooltip('Hồ sơ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quản lý danh mục'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Thêm danh mục'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Cà phê sáng');
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    expect(find.text('Cà phê sáng'), findsOneWidget);

    // Duplicate names are refused.
    await tester.tap(find.byTooltip('Thêm danh mục'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'cà phê sáng');
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    expect(find.text('Tên này đã được dùng'), findsOneWidget);
    await tester.tap(find.byTooltip('Hủy'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Tổng quan'));
    await tester.pumpAndSettle();
    await openAddForm(tester);
    await tester.tap(find.byKey(const ValueKey('category')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cà phê sáng'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('category')),
        matching: find.text('Cà phê sáng'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('History filters combine and reset', (tester) async {
    final container = await pumpApp(tester);

    await tester.tap(find.byTooltip('Giao dịch'));
    await tester.pumpAndSettle();

    // Account: Vietcombank keeps salary and transfers, drops cash spending.
    await tester.ensureVisible(find.byKey(const ValueKey('filter_account')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('filter_account')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vietcombank').last);
    await tester.pumpAndSettle();
    // Coffee is always paid in cash in the demo data.
    expect(find.text('Cà phê'), findsNothing);

    // Time: this month only.
    await tester.ensureVisible(find.byKey(const ValueKey('filter_time')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('filter_time')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tháng này'));
    await tester.pumpAndSettle();
    final query = container.read(transactionsQueryProvider);
    expect(query.accountId, 'acc-bank');
    expect(query.period, PeriodPreset.thisMonth);
    expect(find.textContaining('tháng 9'), findsNothing);

    // Type income narrows the category list to income categories.
    final incomeChip = find.widgetWithText(ChoiceChip, 'Khoản thu');
    await tester.ensureVisible(incomeChip);
    await tester.pumpAndSettle();
    await tester.tap(incomeChip);
    await tester.pumpAndSettle();

    // Category: salary only.
    await tester.ensureVisible(find.byKey(const ValueKey('filter_category')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('filter_category')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lương').last);
    await tester.pumpAndSettle();
    expect(find.text('Rút tiền ATM'), findsNothing);
    expect(find.text('Lương'), findsWidgets);
    expect(find.text('1 giao dịch'), findsOneWidget);

    await tester.ensureVisible(find.byTooltip('Xóa bộ lọc'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Xóa bộ lọc'));
    await tester.pumpAndSettle();
    expect(container.read(transactionsQueryProvider).isFiltered, isFalse);
    expect(find.text('Cà phê'), findsWidgets);
  });

  testWidgets('Customize calendar changes the day tiles live', (tester) async {
    final container = await pumpApp(tester);
    Finder badgeOnDay6(String text) =>
        find.descendant(of: dayCell(6), matching: find.text(text));
    expect(badgeOnDay6('+5'), findsOneWidget); // stacked: 2 shown of 7

    await tester.tap(find.byTooltip('Tùy chỉnh lịch'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Xòe quạt'));
    await tester.pumpAndSettle();
    expect(badgeOnDay6('+4'), findsOneWidget); // fan: 3 shown

    await tester.tap(find.text('Một ảnh'));
    await tester.pumpAndSettle();
    expect(badgeOnDay6('+6'), findsOneWidget); // single: 1 shown

    await tester.scrollUntilVisible(
      find.text('Hiện số giao dịch thêm'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(CustomizeGridSheet),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hiện số giao dịch thêm'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: dayCell(6), matching: find.textContaining('+')),
      findsNothing,
    );

    await tester.tap(find.text('Xong'));
    await tester.pumpAndSettle();
    final settings = container.read(calendarGridSettingsProvider);
    expect(settings.display, GridDisplay.single);
    expect(settings.showBadge, isFalse);
  });
}

class _FailingSaveRepository extends InMemoryLedgerRepository {
  _FailingSaveRepository(DateTime anchor)
    : super(
        accounts: mockAccounts,
        transactions: buildMockTransactions(anchor),
      );

  @override
  Future<MoneyTransaction> saveTransaction(
    MoneyTransaction transaction, {
    MoneyTransaction? previous,
  }) async => throw const LedgerException('offline');
}

class _SignedOut extends CurrentUserNotifier {
  _SignedOut() : super(null) {
    state = null;
  }
}
