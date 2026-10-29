import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/navigation.dart';
import '../../../../core/formatting/formatters.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/ledger.dart';
import '../../domain/ledger_repository.dart';
import '../../domain/models.dart';
import '../../providers/transactions_provider.dart';
import '../category_presentation.dart';
import '../form/capture_photo_screen.dart';
import '../form/keypad_expression.dart';
import '../form/widgets/account_picker_sheet.dart';
import '../form/widgets/amount_keypad.dart';
import '../form/widgets/category_picker_sheet.dart';
import '../form/widgets/day_picker_sheet.dart';
import '../widgets/transaction_list_item.dart';

/// Full-screen cards for a set of transactions (usually one day). Swipe
/// between them; category, account, day, amount, note and photo are edited
/// in place and saved right away.
class TransactionViewerScreen extends ConsumerStatefulWidget {
  /// Ids in display order; the screen follows ledger updates by id.
  final List<String> transactionIds;
  final int initialIndex;

  const TransactionViewerScreen({
    super.key,
    required this.transactionIds,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<TransactionViewerScreen> createState() =>
      _TransactionViewerScreenState();
}

class _TransactionViewerScreenState
    extends ConsumerState<TransactionViewerScreen> {
  late final PageController _pages;
  late int _index;

  /// The amount being typed on the keypad; null while the keypad is closed.
  KeypadExpression? _amount;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pages = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  List<MoneyTransaction> _visible() {
    final byId = {for (final t in ref.watch(transactionsProvider)) t.id: t};
    return [
      for (final id in widget.transactionIds)
        if (byId[id] != null) byId[id]!,
    ];
  }

  /// Money leaving [account] beyond its balance (without [t]'s saved
  /// version) is refused, like on the entry screen.
  bool _overdraws(MoneyTransaction t) {
    final accountId = switch (t.type) {
      TransactionType.expense => t.accountId,
      TransactionType.transfer => t.sourceAccountId,
      TransactionType.income => null,
    };
    final account = ref.read(accountByIdProvider)[accountId];
    if (account == null) return false;
    final others = ref.read(transactionsProvider).where((o) => o.id != t.id);
    return t.amountMinor > accountBalance(account, others);
  }

  Future<bool> _save(MoneyTransaction updated) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    if (_overdraws(updated)) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.errorInsufficientBalance)));
      return false;
    }
    try {
      await ref.read(ledgerProvider.notifier).save(updated);
      return true;
    } on LedgerException {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.saveFailed)));
      return false;
    }
  }

  Future<void> _pickCategory(MoneyTransaction t) async {
    final picked = await showCategoryPicker(
      context,
      type: t.type,
      selected: t.category,
    );
    if (picked != null) await _save(t.copyWith(category: picked));
  }

  Future<void> _pickAccount(MoneyTransaction t) async {
    final id = await showAccountPicker(
      context,
      title: AppLocalizations.of(context).accountLabel,
      accounts: ref.read(accountsProvider),
      balances: ref.read(accountBalancesProvider),
      selectedId: t.accountId,
    );
    if (id != null) await _save(t.copyWith(accountId: id));
  }

  Future<void> _pickDay(MoneyTransaction t) async {
    final picked = await showDayPicker(
      context,
      initial: t.occurredAt,
      today: dateOnly(ref.read(clockProvider)()),
    );
    if (picked == null) return;
    final at = t.occurredAt;
    await _save(
      t.copyWith(
        occurredAt: DateTime(
          picked.year,
          picked.month,
          picked.day,
          at.hour,
          at.minute,
        ),
      ),
    );
  }

  Future<void> _pickPhoto(MoneyTransaction t) async {
    final photo = await pickFromLibrary(context);
    if (photo != null) await _save(t.copyWith(photo: photo));
  }

  Future<void> _amountDone(MoneyTransaction t) async {
    final value = _amount?.evaluate();
    if (value == null || value <= 0) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).errorAmountPositive),
          ),
        );
      return;
    }
    if (value == t.amountMinor || await _save(t.copyWith(amountMinor: value))) {
      if (mounted) setState(() => _amount = null);
    }
  }

  Future<void> _delete(MoneyTransaction t) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(l10n.deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(ledgerProvider.notifier).delete(t);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.deleted)));
    } on LedgerException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.deleteFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fmt = Formatters.of(context);
    final items = _visible();
    if (items.isEmpty) {
      // Everything here was deleted.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).maybePop();
      });
      return const Scaffold(backgroundColor: _background);
    }
    final index = _index.clamp(0, items.length - 1);
    final current = items[index];

    return Scaffold(
      backgroundColor: _background,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                0,
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        PopupMenuButton<String>(
                          tooltip: l10n.moreActions,
                          icon: const Icon(
                            Icons.more_horiz_rounded,
                            color: Colors.white,
                          ),
                          onSelected: (action) => switch (action) {
                            'edit' => openEditTransaction(context, current),
                            _ => _delete(current),
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text(l10n.editDetails),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(l10n.delete),
                            ),
                          ],
                        ),
                        if (current.type != TransactionType.transfer)
                          IconButton(
                            tooltip: l10n.changePhoto,
                            icon: const Icon(
                              Icons.photo_library_outlined,
                              color: Colors.white,
                            ),
                            onPressed: () => _pickPhoto(current),
                          ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: l10n.close,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.12),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: ActionChip(
                key: const ValueKey('viewer_date'),
                avatar: const Icon(Icons.calendar_month_rounded, size: 18),
                label: Text(
                  l10n.dateAtTime(
                    fmt.fullDate(current.occurredAt),
                    fmt.time(current.occurredAt),
                  ),
                ),
                shape: const StadiumBorder(),
                onPressed: () => _pickDay(current),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: PageView.builder(
                controller: _pages,
                itemCount: items.length,
                onPageChanged: (i) => setState(() {
                  _index = i;
                  _amount = null;
                }),
                itemBuilder: (context, i) => _ViewerCard(
                  key: ValueKey(items[i].id),
                  transaction: items[i],
                  amountText: i == index && _amount != null
                      ? (_amount!.isEmpty
                            ? '0'
                            : _amount!.format(fmt.groupDigits))
                      : null,
                  onTapCategory: () => _pickCategory(items[i]),
                  onTapAccount: () => _pickAccount(items[i]),
                  onTapAmount: () => setState(
                    () => _amount = KeypadExpression.fromAmount(
                      items[i].amountMinor,
                    ),
                  ),
                  onNoteChanged: (note) => _save(items[i].copyWith(note: note)),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (_amount == null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.photo_library_outlined,
                      size: 16,
                      color: Colors.white60,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      l10n.viewerPosition(index + 1, items.length),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  0,
                  AppSpacing.sm,
                  AppSpacing.sm,
                ),
                child: AmountKeypad(
                  accent: amountColor(context, current.type),
                  onDigits: (d) =>
                      setState(() => _amount = _amount!.appendDigits(d)),
                  onOp: (op) => setState(() => _amount = _amount!.appendOp(op)),
                  onClear: () =>
                      setState(() => _amount = const KeypadExpression.empty()),
                  onBackspace: () =>
                      setState(() => _amount = _amount!.backspace()),
                  onDone: () => _amountDone(current),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

const _background = Color(0xFF121212);

class _ViewerCard extends ConsumerStatefulWidget {
  final MoneyTransaction transaction;

  /// Expression being typed, shown instead of the saved amount.
  final String? amountText;
  final VoidCallback onTapCategory;
  final VoidCallback onTapAccount;
  final VoidCallback onTapAmount;
  final ValueChanged<String> onNoteChanged;

  const _ViewerCard({
    super.key,
    required this.transaction,
    required this.amountText,
    required this.onTapCategory,
    required this.onTapAccount,
    required this.onTapAmount,
    required this.onNoteChanged,
  });

  @override
  ConsumerState<_ViewerCard> createState() => _ViewerCardState();
}

class _ViewerCardState extends ConsumerState<_ViewerCard> {
  late final _note = TextEditingController(text: widget.transaction.note);
  final _noteFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _noteFocus.addListener(() {
      if (!_noteFocus.hasFocus) _commitNote();
    });
  }

  @override
  void didUpdateWidget(_ViewerCard old) {
    super.didUpdateWidget(old);
    if (!_noteFocus.hasFocus &&
        widget.transaction.note != old.transaction.note) {
      _note.text = widget.transaction.note ?? '';
    }
  }

  @override
  void dispose() {
    _note.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  void _commitNote() {
    if (_note.text.trim() != (widget.transaction.note ?? '')) {
      widget.onNoteChanged(_note.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fmt = Formatters.of(context);
    final colors = AppColors.of(context);
    final accounts = ref.watch(accountByIdProvider);
    final t = widget.transaction;
    final isTransfer = t.type == TransactionType.transfer;
    final tint = isTransfer
        ? colors.transfer
        : (t.category?.tint ?? colors.textSecondary);
    final dark = Color.lerp(tint, Colors.black, 0.75)!;
    final photo = t.photo;

    Widget chip({
      required Key key,
      required IconData? icon,
      required String label,
      VoidCallback? onTap,
    }) {
      return Material(
        key: key,
        color: Colors.black.withValues(alpha: 0.4),
        shape: StadiumBorder(
          side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: Colors.white),
                  const SizedBox(width: AppSpacing.xs),
                ],
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (onTap != null)
                  const Icon(
                    Icons.expand_more_rounded,
                    size: 18,
                    color: Colors.white70,
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (photo != null)
              Image(
                image: photo.imageProvider,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => ColoredBox(color: dark),
              )
            else
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [tint, dark],
                  ),
                ),
                child: Center(
                  child: Icon(
                    isTransfer
                        ? Icons.swap_horiz_rounded
                        : (t.category?.icon ?? Icons.category_rounded),
                    size: 72,
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                ),
              ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x55000000),
                    Color(0x00000000),
                    Color(0xAA000000),
                  ],
                  stops: [0, 0.35, 1],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: isTransfer
                        ? [
                            chip(
                              key: const ValueKey('viewer_from'),
                              icon: accounts[t.sourceAccountId]?.type.icon,
                              label: accounts[t.sourceAccountId]?.name ?? '',
                            ),
                            chip(
                              key: const ValueKey('viewer_to'),
                              icon: accounts[t.destinationAccountId]?.type.icon,
                              label:
                                  accounts[t.destinationAccountId]?.name ?? '',
                            ),
                          ]
                        : [
                            chip(
                              key: const ValueKey('viewer_category'),
                              icon: t.category?.icon,
                              label: t.category?.label(l10n) ?? '',
                              onTap: widget.onTapCategory,
                            ),
                            chip(
                              key: const ValueKey('viewer_account'),
                              icon: accounts[t.accountId]?.type.icon,
                              label: accounts[t.accountId]?.name ?? '',
                              onTap: widget.onTapAccount,
                            ),
                          ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    key: const ValueKey('viewer_amount'),
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.onTapAmount,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          if (!isTransfer)
                            Text(
                              t.type == TransactionType.expense ? '− ' : '+ ',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                color: amountColor(context, t.type),
                              ),
                            ),
                          Text(
                            widget.amountText ?? fmt.groupDigits(t.amountMinor),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          const Text(
                            ' ₫',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  TextField(
                    key: const ValueKey('viewer_note'),
                    controller: _note,
                    focusNode: _noteFocus,
                    textAlign: TextAlign.center,
                    maxLength: 300,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _noteFocus.unfocus(),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: l10n.addNotePlaceholder,
                      hintStyle: const TextStyle(color: Colors.white54),
                      counterText: '',
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
