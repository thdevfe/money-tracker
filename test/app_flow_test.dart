import 'package:expense_tracker/app/app.dart';
import 'package:expense_tracker/features/transactions/domain/models.dart';
import 'package:expense_tracker/features/transactions/presentation/form/widgets/account_selector.dart';
import 'package:expense_tracker/features/transactions/presentation/home/widgets/photo_calendar_day_cell.dart';
import 'package:expense_tracker/features/transactions/providers/transactions_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _now = DateTime(2026, 10, 24, 20, 30);

Future<ProviderContainer> pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: [clockProvider.overrideWithValue(() => _now)],
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

Future<void> openAddForm(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Thêm giao dịch'));
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
    await tester.enterText(find.byType(TextField).first, '120000');
    await tester.tap(find.text('Ăn uống'));
    await tester.pump();
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();

    expect(find.text('Đã thêm giao dịch'), findsOneWidget);
    final items = container.read(transactionsProvider);
    expect(items.length, before + 1);
    final added = items.firstWhere((t) => t.amountMinor == 120000);
    expect(added.photo, isNull);
    expect(added.category, CategoryCode.food);
    // Defaults to the day selected on Home.
    expect(added.occurredAt.day, 24);
  });

  testWidgets('Form validation blocks invalid amounts and categories', (
    tester,
  ) async {
    final container = await pumpApp(tester);
    final before = container.read(transactionsProvider).length;

    await openAddForm(tester);
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    expect(find.text('Nhập số tiền'), findsOneWidget);
    expect(find.text('Chọn danh mục'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '0');
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    expect(find.text('Số tiền phải lớn hơn 0'), findsOneWidget);
    expect(container.read(transactionsProvider).length, before);
  });

  testWidgets('Transfer hides category/photo and rejects the same account', (
    tester,
  ) async {
    await pumpApp(tester);
    await openAddForm(tester);

    await tester.tap(find.text('Chuyển khoản'));
    await tester.pumpAndSettle();
    expect(find.text('Danh mục'), findsNothing);
    expect(find.text('Ảnh (không bắt buộc)'), findsNothing);

    await tester.enterText(find.byType(TextField).first, '50000');
    // Change destination to the source account (Vietcombank).
    await tester.tap(find.widgetWithText(AccountSelector, 'Đến tài khoản'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vietcombank').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();

    expect(find.text('Chọn hai tài khoản khác nhau'), findsOneWidget);
  });

  testWidgets('Leaving with unsaved changes asks for confirmation', (
    tester,
  ) async {
    await pumpApp(tester);
    await openAddForm(tester);

    await tester.enterText(find.byType(TextField).first, '1000');
    await tester.pump();
    await tester.tap(find.text('Hủy'));
    await tester.pumpAndSettle();
    expect(find.text('Bỏ các thay đổi?'), findsOneWidget);

    await tester.tap(find.text('Bỏ thay đổi'));
    await tester.pumpAndSettle();
    expect(find.text('Giao dịch mới'), findsNothing);
  });

  testWidgets('Editing opens the existing transaction', (tester) async {
    await pumpApp(tester);

    // Scroll the day preview above the floating nav bar.
    await tester.drag(find.byType(ListView).first, const Offset(0, -600));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mua sắm').first);
    await tester.pumpAndSettle();

    expect(find.text('Sửa giao dịch'), findsOneWidget);
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
}
