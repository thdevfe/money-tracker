import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/navigation.dart';
import '../../../../core/formatting/formatters.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/ledger.dart';
import '../../domain/ledger_repository.dart';
import '../../domain/models.dart';
import '../../providers/transactions_provider.dart';
import '../category_presentation.dart';
import '../widgets/transaction_list_item.dart';
import 'capture_photo_screen.dart';
import 'keypad_expression.dart';
import 'transaction_form_validation.dart';
import 'widgets/account_picker_sheet.dart';
import 'widgets/amount_keypad.dart';
import 'widgets/day_picker_sheet.dart';
import 'widgets/picker_chip.dart';

/// Step 2 of adding (and the edit screen): a hero card with the photo or the
/// category, the amount, quick pickers and a calculator keypad.
class AddEditTransactionScreen extends ConsumerStatefulWidget {
  final MoneyTransaction? existing;

  /// Default day for a new transaction (time defaults to now).
  final DateTime? initialDate;

  /// Photo taken or chosen in the capture step.
  final TransactionPhoto? initialPhoto;

  const AddEditTransactionScreen({
    super.key,
    this.existing,
    this.initialDate,
    this.initialPhoto,
  });

  @override
  ConsumerState<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState
    extends ConsumerState<AddEditTransactionScreen> {
  static const _uuid = Uuid();

  late TransactionType _type;
  Category? _category;
  late String _accountId;
  late String _sourceAccountId;
  late String _destinationAccountId;
  late DateTime _occurredAt;
  late String _note;
  TransactionPhoto? _photo;
  late KeypadExpression _amount;

  late final int _initialSnapshot;
  bool _submitted = false;
  bool _saving = false;
  bool _allowPop = false;

  /// The keypad slides in for typing; with it closed the photo shows in
  /// full and the bottom bar saves.
  late bool _keypadOpen;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    final now = ref.read(clockProvider)();
    _type = e?.type ?? TransactionType.expense;
    _category = e?.category ?? _defaultCategory(_type);
    // Defaults: spend from cash, transfer from bank to cash.
    final accounts = ref.read(accountsProvider);
    String? firstOf(AccountType type) =>
        accounts.where((a) => a.type == type).firstOrNull?.id;
    final fallback = accounts.firstOrNull?.id ?? '';
    _accountId = e?.accountId ?? firstOf(AccountType.cash) ?? fallback;
    _sourceAccountId =
        e?.sourceAccountId ?? firstOf(AccountType.bank) ?? fallback;
    _destinationAccountId =
        e?.destinationAccountId ??
        accounts.where((a) => a.id != _sourceAccountId).firstOrNull?.id ??
        fallback;
    final day = widget.initialDate;
    _occurredAt =
        e?.occurredAt ??
        (day == null
            ? now
            : DateTime(day.year, day.month, day.day, now.hour, now.minute));
    _note = e?.note ?? '';
    _photo = e?.photo ?? widget.initialPhoto;
    _amount = e == null
        ? const KeypadExpression.empty()
        : KeypadExpression.fromAmount(e.amountMinor);
    // Without a photo there is nothing to look at: start typing right away.
    _keypadOpen = e == null && _photo == null;
    // Baseline for "unsaved changes"; a fresh photo counts as a change.
    _initialSnapshot = _snapshot(e?.amountMinor, photo: e?.photo);
  }

  static Category? _defaultCategory(TransactionType type) =>
      type == TransactionType.transfer ? null : Category.systemFor(type).first;

  int? get _amountMinor => _amount.evaluate();

  /// Hash of the editable values, used to detect unsaved changes.
  int _snapshot(int? amountMinor, {required TransactionPhoto? photo}) =>
      Object.hashAll([
        _type,
        amountMinor,
        _category,
        _accountId,
        _sourceAccountId,
        _destinationAccountId,
        _occurredAt,
        _note.trim(),
        photo,
      ]);

  bool get _isDirty =>
      _snapshot(_amountMinor, photo: _photo) != _initialSnapshot;

  TransactionFormErrors get _errors => validateTransactionForm(
    type: _type,
    amountMinor: _amountMinor,
    category: _category,
    sourceAccountId: _sourceAccountId,
    destinationAccountId: _destinationAccountId,
    availableMinor: _availableBalance(),
  );

  /// Balance of the account money leaves, ignoring this transaction's saved
  /// version so an edit isn't counted twice. Null for income.
  int? _availableBalance() {
    if (_type == TransactionType.income) return null;
    final id = _type == TransactionType.transfer
        ? _sourceAccountId
        : _accountId;
    final account = ref.read(accountByIdProvider)[id];
    if (account == null) return null;
    final others = ref
        .read(transactionsProvider)
        .where((t) => t.id != widget.existing?.id);
    return accountBalance(account, others);
  }

  void _changeType(TransactionType type) {
    if (type == _type || _isEditing) return;
    setState(() {
      _type = type;
      _category = _defaultCategory(type);
      if (type == TransactionType.transfer) _photo = null;
    });
  }

  void _updateAmount(KeypadExpression next) => setState(() => _amount = next);

  Future<void> _pickDate() async {
    final picked = await showDayPicker(
      context,
      initial: _occurredAt,
      today: dateOnly(ref.read(clockProvider)()),
    );
    if (picked == null) return;
    setState(() {
      _occurredAt = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _occurredAt.hour,
        _occurredAt.minute,
      );
    });
  }

  Future<void> _pickCategory() async {
    final l10n = AppLocalizations.of(context);
    // Expense / income tabs, like the type toggle; locked while editing.
    var sheetType = _type;
    final picked = await showModalBottomSheet<Category>(
      context: context,
      showDragHandle: true,
      // Scrolls when custom categories make the grid taller than the sheet.
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final options = ref.read(selectableCategoriesProvider(sheetType));
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.chooseCategory,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (!_isEditing) ...[
                    const SizedBox(height: AppSpacing.md),
                    SegmentedButton<TransactionType>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                          value: TransactionType.expense,
                          label: Text(l10n.typeExpense),
                        ),
                        ButtonSegment(
                          value: TransactionType.income,
                          label: Text(l10n.typeIncome),
                        ),
                      ],
                      selected: {sheetType},
                      onSelectionChanged: (s) =>
                          setSheetState(() => sheetType = s.first),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 0.82,
                    children: [
                      for (final c in options)
                        _CategoryOption(
                          category: c,
                          selected: c == _category,
                          onTap: () => Navigator.of(context).pop(c),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      openCategories(this.context, type: sheetType);
                    },
                    icon: const Icon(Icons.tune_rounded),
                    label: Text(l10n.manageCategories),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    if (picked == null) return;
    // A category from the other tab switches the type as well.
    _changeType(picked.type);
    setState(() => _category = picked);
  }

  Future<void> _pickAccount({
    required String title,
    required String selectedId,
    required ValueChanged<String> onPicked,
  }) async {
    final id = await showAccountPicker(
      context,
      title: title,
      accounts: ref.read(accountsProvider),
      balances: ref.read(accountBalancesProvider),
      selectedId: selectedId,
    );
    if (id != null) setState(() => onPicked(id));
  }

  /// Photo actions from the hero: retake, library, or remove.
  Future<void> _photoActions() async {
    final l10n = AppLocalizations.of(context);
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(_photo == null ? l10n.takePhoto : l10n.retakePhoto),
              onTap: () => Navigator.of(context).pop('camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.chooseFromLibrary),
              onTap: () => Navigator.of(context).pop('library'),
            ),
            if (_photo != null)
              ListTile(
                leading: Icon(
                  Icons.delete_outline_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(l10n.photoRemove),
                onTap: () => Navigator.of(context).pop('remove'),
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case 'camera':
        final result = await Navigator.of(context).push<CaptureResult>(
          MaterialPageRoute(
            builder: (_) => const CapturePhotoScreen(),
            fullscreenDialog: true,
          ),
        );
        if (result?.photo != null) setState(() => _photo = result!.photo);
      case 'library':
        final photo = await pickFromLibrary(context);
        if (photo != null) setState(() => _photo = photo);
      case 'remove':
        setState(() => _photo = null);
    }
  }

  /// Note and time, in a sheet behind "Add details".
  Future<void> _editDetails() async {
    final l10n = AppLocalizations.of(context);
    final fmt = Formatters.of(context);
    final controller = TextEditingController(text: _note);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg + MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: StatefulBuilder(
          builder: (sheetContext, setSheetState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                maxLength: 300,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => Navigator.of(sheetContext).pop(),
                decoration: InputDecoration(
                  labelText: l10n.noteLabel,
                  hintText: l10n.noteHint,
                  counterText: '',
                  prefixIcon: const Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule_rounded),
                title: Text(l10n.timeLabel),
                trailing: Text(
                  fmt.time(_occurredAt),
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: sheetContext,
                    initialTime: TimeOfDay.fromDateTime(_occurredAt),
                  );
                  if (picked == null) return;
                  setState(() {
                    _occurredAt = DateTime(
                      _occurredAt.year,
                      _occurredAt.month,
                      _occurredAt.day,
                      picked.hour,
                      picked.minute,
                    );
                  });
                  setSheetState(() {});
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              FilledButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                child: Text(l10n.done),
              ),
            ],
          ),
        ),
      ),
    );
    setState(() => _note = controller.text);
    controller.dispose();
  }

  /// Keypad Done: closes the keypad once the amount is valid.
  void _keypadDone() {
    if (_errors.amount != null) {
      setState(() => _submitted = true);
      return;
    }
    setState(() => _keypadOpen = false);
  }

  Future<void> _save({bool next = false}) async {
    if (_saving) return;
    setState(() => _submitted = true);
    if (!_errors.isValid) {
      if (_errors.amount != null) setState(() => _keypadOpen = true);
      return;
    }

    setState(() => _saving = true);
    final isTransfer = _type == TransactionType.transfer;
    final note = _note.trim();
    final transaction = MoneyTransaction(
      id: widget.existing?.id ?? _uuid.v4(),
      type: _type,
      amountMinor: _amountMinor!,
      occurredAt: _occurredAt,
      accountId: isTransfer ? null : _accountId,
      category: isTransfer ? null : _category,
      sourceAccountId: isTransfer ? _sourceAccountId : null,
      destinationAccountId: isTransfer ? _destinationAccountId : null,
      note: note.isEmpty ? null : note,
      photo: isTransfer ? null : _photo,
    );
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(ledgerProvider.notifier).save(transaction);
    } on LedgerException {
      // Keep everything the user entered so they can retry.
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(l10n.saveFailed)));
      return;
    }
    if (!mounted) return;
    _close(
      _isEditing
          ? TransactionFormResult.updated
          : next
          ? TransactionFormResult.addedNext
          : TransactionFormResult.added,
    );
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
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
    if (confirmed != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(ledgerProvider.notifier).delete(widget.existing!);
    } on LedgerException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.deleteFailed)));
      return;
    }
    if (!mounted) return;
    _close(TransactionFormResult.deleted);
  }

  void _close([TransactionFormResult? result]) {
    setState(() => _allowPop = true);
    Navigator.of(context).pop(result);
  }

  Future<void> _confirmDiscard() async {
    final l10n = AppLocalizations.of(context);
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.discardTitle),
        content: Text(l10n.discardMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.keepEditing),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.discard),
          ),
        ],
      ),
    );
    if (discard == true && mounted) _close();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fmt = Formatters.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final accounts = ref.watch(accountByIdProvider);
    final errors = _submitted ? _errors : const TransactionFormErrors();
    final isTransfer = _type == TransactionType.transfer;
    final accent = amountColor(context, _type);
    final today = dateOnly(ref.watch(clockProvider)());

    final amountError = switch (errors.amount) {
      AmountError.required => l10n.errorAmountRequired,
      AmountError.notPositive => l10n.errorAmountPositive,
      AmountError.tooLarge => l10n.errorAmountTooLarge,
      null => null,
    };
    final day = dateOnly(_occurredAt);
    final dateLabel =
        isSameDay(day, today) ||
            isSameDay(day, today.subtract(const Duration(days: 1)))
        ? fmt.dayHeading(day, today)
        : fmt.dayMonth(day);

    return PopScope(
      canPop: _allowPop || !_isDirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            Expanded(
              child: _Hero(
                photo: isTransfer ? null : _photo,
                tint: isTransfer
                    ? colors.transfer
                    : (_category?.tint ?? theme.colorScheme.primary),
                icon: isTransfer
                    ? Icons.swap_horiz_rounded
                    : (_category?.icon ?? Icons.category_rounded),
                title: isTransfer
                    ? l10n.typeTransfer
                    : (_category?.label(l10n) ?? ''),
                onTapPhoto: isTransfer ? null : _photoActions,
                onRemovePhoto: isTransfer || _photo == null
                    ? null
                    : () => setState(() => _photo = null),
                onCancel: () => Navigator.of(context).maybePop(),
                onDelete: _isEditing ? _delete : null,
                amountPanel: _AmountPanel(
                  sign: switch (_type) {
                    TransactionType.expense => '−',
                    TransactionType.income => '+',
                    TransactionType.transfer => '',
                  },
                  text: _amount.isEmpty ? '0' : _amount.format(fmt.groupDigits),
                  result: _amount.hasOperator && _amountMinor != null
                      ? '= ${fmt.money(_amountMinor!)}'
                      : null,
                  isPlaceholder: _amount.isEmpty,
                  accent: accent,
                  error: amountError,
                  note: _note.trim(),
                  onAddDetails: _editDetails,
                  onTapAmount: () => setState(() => _keypadOpen = true),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: isTransfer
                    ? [
                        PickerChip(
                          key: const ValueKey('from_account'),
                          icon: accounts[_sourceAccountId]?.type.icon,
                          label: accounts[_sourceAccountId]?.name ?? '',
                          onTap: () => _pickAccount(
                            title: l10n.fromAccountLabel,
                            selectedId: _sourceAccountId,
                            onPicked: (id) => _sourceAccountId = id,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: colors.transfer,
                        ),
                        PickerChip(
                          key: const ValueKey('to_account'),
                          icon: accounts[_destinationAccountId]?.type.icon,
                          label: accounts[_destinationAccountId]?.name ?? '',
                          onTap: () => _pickAccount(
                            title: l10n.toAccountLabel,
                            selectedId: _destinationAccountId,
                            onPicked: (id) => _destinationAccountId = id,
                          ),
                        ),
                      ]
                    : [
                        PickerChip(
                          key: const ValueKey('category'),
                          icon: _category?.icon,
                          iconColor: _category?.tint,
                          label: _category?.label(l10n) ?? l10n.chooseCategory,
                          onTap: _pickCategory,
                        ),
                        PickerChip(
                          key: const ValueKey('account'),
                          icon: accounts[_accountId]?.type.icon,
                          label: accounts[_accountId]?.name ?? '',
                          onTap: () => _pickAccount(
                            title: l10n.accountLabel,
                            selectedId: _accountId,
                            onPicked: (id) => _accountId = id,
                          ),
                        ),
                      ],
              ),
            ),
            if (errors.sameAccount ||
                errors.categoryMissing ||
                errors.insufficientBalance)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  errors.sameAccount
                      ? l10n.errorSameAccount
                      : errors.insufficientBalance
                      ? l10n.errorInsufficientBalance
                      : l10n.errorCategoryRequired,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TypeToggle(
                  selected: _type,
                  enabled: !_isEditing,
                  onChanged: _changeType,
                ),
                const SizedBox(width: AppSpacing.md),
                PickerChip(
                  key: const ValueKey('date'),
                  icon: Icons.calendar_month_rounded,
                  label: dateLabel,
                  onTap: _pickDate,
                ),
              ],
            ),
            if (_isEditing)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  l10n.typeLockedHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            SafeArea(
              top: false,
              minimum: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.bottomCenter,
                  child: _keypadOpen
                      ? AmountKeypad(
                          accent: accent,
                          onDigits: (d) =>
                              _updateAmount(_amount.appendDigits(d)),
                          onOp: (op) => _updateAmount(_amount.appendOp(op)),
                          onClear: () =>
                              _updateAmount(const KeypadExpression.empty()),
                          onBackspace: () => _updateAmount(_amount.backspace()),
                          onDone: _keypadDone,
                        )
                      : _ActionBar(
                          accent: accent,
                          ready: _amountMinor != null && _amountMinor! > 0,
                          onDetails: _editDetails,
                          onSave: _saving ? null : () => _save(),
                          onSaveNext: _isEditing || _saving
                              ? null
                              : () => _save(next: true),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cancel / Delete on top, then a rounded card with the photo (or the
/// category on a tinted gradient) and the amount panel at its bottom.
class _Hero extends StatelessWidget {
  final TransactionPhoto? photo;
  final Color tint;
  final IconData icon;
  final String title;
  final VoidCallback? onTapPhoto;
  final VoidCallback? onRemovePhoto;
  final VoidCallback onCancel;
  final VoidCallback? onDelete;
  final Widget amountPanel;

  const _Hero({
    required this.photo,
    required this.tint,
    required this.icon,
    required this.title,
    required this.onTapPhoto,
    required this.onRemovePhoto,
    required this.onCancel,
    required this.onDelete,
    required this.amountPanel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final current = photo;
    final dark = Color.lerp(tint, Colors.black, 0.75)!;

    Widget pillButton(Widget child, VoidCallback onTap, {String? tooltip}) {
      final button = Material(
        color: scheme.onSurface.withValues(alpha: 0.08),
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Center(widthFactor: 1, child: child),
            ),
          ),
        ),
      );
      return tooltip == null
          ? button
          : Tooltip(message: tooltip, child: button);
    }

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                pillButton(
                  Text(
                    l10n.cancel,
                    style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onCancel,
                ),
                const Spacer(),
                if (onDelete != null)
                  pillButton(
                    Icon(Icons.delete_outline_rounded, color: scheme.error),
                    onDelete!,
                    tooltip: l10n.delete,
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (current != null)
                      Image(
                        image: current.imageProvider,
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
                      ),
                    // Keeps the amount readable over bright photos.
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x00000000), Color(0x99000000)],
                          stops: [0.4, 1],
                        ),
                      ),
                    ),
                    if (onTapPhoto != null)
                      Semantics(
                        button: true,
                        label: current == null
                            ? l10n.takePhoto
                            : l10n.changePhoto,
                        excludeSemantics: true,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onTapPhoto,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        children: [
                          if (current == null)
                            Expanded(
                              child: IgnorePointer(
                                // Scales down on short screens.
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: _HeroCategory(
                                    icon: icon,
                                    title: title,
                                    showPhotoHint: onTapPhoto != null,
                                  ),
                                ),
                              ),
                            )
                          else
                            const Spacer(),
                          amountPanel,
                        ],
                      ),
                    ),
                    if (onRemovePhoto != null)
                      Positioned(
                        top: AppSpacing.md,
                        right: AppSpacing.md,
                        child: IconButton(
                          tooltip: l10n.photoRemove,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black.withValues(
                              alpha: 0.45,
                            ),
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.close_rounded),
                          onPressed: onRemovePhoto,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Category icon and name shown on the card when there is no photo.
class _HeroCategory extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool showPhotoHint;

  const _HeroCategory({
    required this.icon,
    required this.title,
    required this.showPhotoHint,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 40, color: Colors.white),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (showPhotoHint) ...[
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.add_a_photo_outlined,
                size: 14,
                color: Colors.white70,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                l10n.takePhoto,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Shown while the keypad is closed: note, a large save check and
/// "Add" (save, then start the next entry).
class _ActionBar extends StatelessWidget {
  final Color accent;
  final bool ready;
  final VoidCallback onDetails;
  final VoidCallback? onSave;
  final VoidCallback? onSaveNext;

  const _ActionBar({
    required this.accent,
    required this.ready,
    required this.onDetails,
    required this.onSave,
    required this.onSaveNext,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);

    Widget side({
      required Key key,
      required IconData icon,
      required String label,
      required VoidCallback? onTap,
      Color? color,
    }) {
      return SizedBox(
        width: 88,
        child: Opacity(
          opacity: onTap == null ? 0.35 : 1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton.filledTonal(
                key: key,
                tooltip: label,
                style: IconButton.styleFrom(
                  fixedSize: const Size(52, 52),
                  foregroundColor: color,
                  backgroundColor: (color ?? colors.textSecondary).withValues(
                    alpha: 0.16,
                  ),
                ),
                icon: Icon(icon),
                onPressed: onTap,
              ),
              const SizedBox(height: 2),
              ExcludeSemantics(
                child: Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: colors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          side(
            key: const ValueKey('details'),
            icon: Icons.edit_note_rounded,
            label: l10n.noteShort,
            onTap: onDetails,
          ),
          Semantics(
            button: true,
            label: l10n.save,
            excludeSemantics: true,
            child: GestureDetector(
              key: const ValueKey('save'),
              onTap: onSave,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 80,
                height: 80,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ready ? accent : colors.textSecondary,
                    width: 3,
                  ),
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ready ? accent : colors.elevatedSurface,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 38,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          side(
            key: const ValueKey('save_next'),
            icon: Icons.add_rounded,
            label: l10n.saveAndAddNext,
            onTap: onSaveNext,
            color: accent,
          ),
        ],
      ),
    );
  }
}

/// Frosted panel with the signed amount and an "Add details" pill.
class _AmountPanel extends StatelessWidget {
  final String sign;
  final String text;
  final String? result;
  final bool isPlaceholder;
  final Color accent;
  final String? error;
  final String note;
  final VoidCallback onAddDetails;
  final VoidCallback onTapAmount;

  const _AmountPanel({
    required this.sign,
    required this.text,
    required this.result,
    required this.isPlaceholder,
    required this.accent,
    required this.error,
    required this.note,
    required this.onAddDetails,
    required this.onTapAmount,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                key: const ValueKey('amount'),
                behavior: HitTestBehavior.opaque,
                onTap: onTapAmount,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (sign.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: Text(
                            sign,
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: accent,
                            ),
                          ),
                        ),
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          color: isPlaceholder ? Colors.white54 : Colors.white,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Text(
                        '₫',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (result != null)
                Text(
                  result!,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    error!,
                    style: const TextStyle(
                      color: Color(0xFFFFB4B6),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              Material(
                color: Colors.white.withValues(alpha: 0.10),
                shape: StadiumBorder(
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
                ),
                child: InkWell(
                  customBorder: const StadiumBorder(),
                  onTap: onAddDetails,
                  child: SizedBox(
                    height: 44,
                    child: Row(
                      children: [
                        const SizedBox(width: AppSpacing.lg),
                        const Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: Colors.white60,
                        ),
                        Expanded(
                          child: Text(
                            note.isEmpty ? l10n.addDetails : note,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: note.isEmpty
                                  ? Colors.white60
                                  : Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg + 18),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Round expense / income / transfer switch.
class _TypeToggle extends StatelessWidget {
  final TransactionType selected;
  final bool enabled;
  final ValueChanged<TransactionType> onChanged;

  const _TypeToggle({
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final type in TransactionType.values)
            Tooltip(
              message: type.label(l10n),
              child: Semantics(
                button: true,
                selected: type == selected,
                label: type.label(l10n),
                excludeSemantics: true,
                child: GestureDetector(
                  onTap: enabled ? () => onChanged(type) : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: type == selected ? 60 : 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: type == selected
                          ? amountColor(context, type)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Icon(
                      type.icon,
                      size: 20,
                      color: type == selected
                          ? Colors.white
                          : colors.textSecondary.withValues(
                              alpha: enabled ? 1 : 0.4,
                            ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryOption extends StatelessWidget {
  final Category category;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryOption({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.card),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: category.tint,
              borderRadius: BorderRadius.circular(AppRadii.card),
              border: selected
                  ? Border.all(color: theme.colorScheme.onSurface, width: 2.5)
                  : null,
            ),
            child: Icon(category.icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            category.label(l10n),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
