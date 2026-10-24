import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/navigation.dart';
import '../../../../core/formatting/formatters.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/mock_data.dart';
import '../../domain/models.dart';
import '../../providers/transactions_provider.dart';
import '../widgets/transaction_list_item.dart';
import 'transaction_form_validation.dart';
import 'widgets/account_selector.dart';
import 'widgets/amount_input.dart';
import 'widgets/category_selector.dart';
import 'widgets/optional_photo_picker.dart';
import 'widgets/transaction_type_selector.dart';

class AddEditTransactionScreen extends ConsumerStatefulWidget {
  final MoneyTransaction? existing;

  /// Default day for a new transaction (time defaults to now).
  final DateTime? initialDate;

  const AddEditTransactionScreen({super.key, this.existing, this.initialDate});

  @override
  ConsumerState<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState
    extends ConsumerState<AddEditTransactionScreen> {
  static const _uuid = Uuid();

  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  late TransactionType _type;
  CategoryCode? _category;
  late String _accountId;
  late String _sourceAccountId;
  late String _destinationAccountId;
  late DateTime _occurredAt;
  TransactionPhoto? _photo;

  late final int _initialSnapshot;
  bool _submitted = false;
  bool _saving = false;
  bool _allowPop = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    final now = ref.read(clockProvider)();
    _type = e?.type ?? TransactionType.expense;
    _category = e?.category;
    _accountId = e?.accountId ?? cashAccountId;
    _sourceAccountId = e?.sourceAccountId ?? bankAccountId;
    _destinationAccountId = e?.destinationAccountId ?? cashAccountId;
    final day = widget.initialDate;
    _occurredAt =
        e?.occurredAt ??
        (day == null
            ? now
            : DateTime(day.year, day.month, day.day, now.hour, now.minute));
    _noteController.text = e?.note ?? '';
    _photo = e?.photo;
    _initialSnapshot = _snapshot(e?.amountMinor);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Format the existing amount once the locale is available.
    final e = widget.existing;
    if (e != null && _amountController.text.isEmpty) {
      _amountController.text = Formatters.of(
        context,
      ).groupDigits(e.amountMinor);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  int? get _amountMinor => parseAmountMinor(_amountController.text);

  /// Hash of the editable values, used to detect unsaved changes.
  int _snapshot(int? amountMinor) => Object.hashAll([
    _type,
    amountMinor,
    _category,
    _accountId,
    _sourceAccountId,
    _destinationAccountId,
    _occurredAt,
    _noteController.text.trim(),
    _photo,
  ]);

  bool get _isDirty => _snapshot(_amountMinor) != _initialSnapshot;

  TransactionFormErrors get _errors => validateTransactionForm(
    type: _type,
    amountMinor: _amountMinor,
    category: _category,
    sourceAccountId: _sourceAccountId,
    destinationAccountId: _destinationAccountId,
  );

  void _changeType(TransactionType type) {
    if (type == _type) return;
    setState(() {
      _type = type;
      _category = null;
      if (type == TransactionType.transfer) _photo = null;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
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

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
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
  }

  Future<void> _pickPhoto(ImageSource source) async {
    FocusScope.of(context).unfocus();
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;
      final provider = kIsWeb
          ? NetworkImage(file.path) as ImageProvider
          : FileImage(File(file.path));
      setState(() => _photo = PickedTransactionPhoto(file.path, provider));
    } on PlatformException {
      // Permission denied or no camera (e.g. the simulator).
      messenger.showSnackBar(SnackBar(content: Text(l10n.photoPickError)));
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
    if (!_errors.isValid) return;

    setState(() => _saving = true);
    final isTransfer = _type == TransactionType.transfer;
    final note = _noteController.text.trim();
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
    final notifier = ref.read(transactionsProvider.notifier);
    if (_isEditing) {
      notifier.update(transaction);
    } else {
      notifier.add(transaction);
    }
    _close(
      _isEditing ? TransactionFormResult.updated : TransactionFormResult.added,
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
    ref.read(transactionsProvider.notifier).delete(widget.existing!.id);
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
    final accounts = ref.watch(accountsProvider);
    final balances = ref.watch(accountBalancesProvider);
    final errors = _submitted ? _errors : const TransactionFormErrors();
    final isTransfer = _type == TransactionType.transfer;

    final amountError = switch (errors.amount) {
      AmountError.required => l10n.errorAmountRequired,
      AmountError.notPositive => l10n.errorAmountPositive,
      AmountError.tooLarge => l10n.errorAmountTooLarge,
      null => null,
    };

    return PopScope(
      canPop: _allowPop || !_isDirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 96,
          leading: TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: Text(l10n.cancel),
          ),
          centerTitle: true,
          title: Text(_isEditing ? l10n.editTitle : l10n.addTitle),
          actions: [
            if (_isEditing)
              IconButton(
                tooltip: l10n.delete,
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: _delete,
              ),
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.xxl,
                  ),
                  children: [
                    TransactionTypeSelector(
                      selected: _type,
                      onChanged: _isEditing ? null : _changeType,
                    ),
                    if (_isEditing)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(
                          l10n.typeLockedHint,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.of(context).textSecondary,
                              ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.xl),
                    AmountInput(
                      controller: _amountController,
                      autofocus: !_isEditing,
                      color: amountColor(context, _type),
                      errorText: amountError,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    if (!isTransfer) ...[
                      CategorySelector(
                        type: _type,
                        selected: _category,
                        errorText: errors.categoryMissing
                            ? l10n.errorCategoryRequired
                            : null,
                        onChanged: (c) => setState(() => _category = c),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AccountSelector(
                        label: l10n.accountLabel,
                        accounts: accounts,
                        balances: balances,
                        selectedId: _accountId,
                        onChanged: (id) => setState(() => _accountId = id),
                      ),
                    ] else ...[
                      AccountSelector(
                        label: l10n.fromAccountLabel,
                        accounts: accounts,
                        balances: balances,
                        selectedId: _sourceAccountId,
                        onChanged: (id) =>
                            setState(() => _sourceAccountId = id),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AccountSelector(
                        label: l10n.toAccountLabel,
                        accounts: accounts,
                        balances: balances,
                        selectedId: _destinationAccountId,
                        errorText: errors.sameAccount
                            ? l10n.errorSameAccount
                            : null,
                        onChanged: (id) =>
                            setState(() => _destinationAccountId = id),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _PickerField(
                            label: l10n.dateLabel,
                            icon: Icons.calendar_today_rounded,
                            value: fmt.shortDate(_occurredAt),
                            onTap: _pickDate,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          flex: 2,
                          child: _PickerField(
                            label: l10n.timeLabel,
                            icon: Icons.schedule_rounded,
                            value: fmt.time(_occurredAt),
                            onTap: _pickTime,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _noteController,
                      maxLength: 300,
                      minLines: 1,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.done,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: l10n.noteLabel,
                        hintText: l10n.noteHint,
                        counterText: '',
                        prefixIcon: const Icon(Icons.notes_rounded),
                      ),
                    ),
                    if (!isTransfer) ...[
                      const SizedBox(height: AppSpacing.xl),
                      OptionalPhotoPicker(
                        photo: _photo,
                        onPick: _pickPhoto,
                        onRemove: () => setState(() => _photo = null),
                      ),
                    ],
                  ],
                ),
              ),
              _SaveBar(label: l10n.save, onPressed: _saving ? null : _save),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom Save button. Sits in the body column so it stays above the keyboard.
class _SaveBar extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _SaveBar({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: AppColors.of(context).border)),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: onPressed, child: Text(label)),
          ),
        ),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final VoidCallback onTap;

  const _PickerField({
    required this.label,
    required this.icon,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.input),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
        ),
        child: Text(value, maxLines: 1),
      ),
    );
  }
}
