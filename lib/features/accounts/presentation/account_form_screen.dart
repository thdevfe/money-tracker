import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/formatting/formatters.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../transactions/domain/ledger_repository.dart';
import '../../transactions/domain/ledger_rules.dart';
import '../../transactions/domain/models.dart';
import '../../transactions/presentation/category_presentation.dart';
import '../../transactions/providers/transactions_provider.dart';

/// Create or edit an account: name, type and opening balance. The opening
/// balance is read-only once the account has transactions.
class AccountFormScreen extends ConsumerStatefulWidget {
  final Account? existing;

  const AccountFormScreen({super.key, this.existing});

  @override
  ConsumerState<AccountFormScreen> createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends ConsumerState<AccountFormScreen> {
  static const _uuid = Uuid();

  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  final _opening = TextEditingController();
  late AccountType _type = widget.existing?.type ?? AccountType.cash;
  bool _submitted = false;
  bool _busy = false;

  bool get _isEditing => widget.existing != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final opening = widget.existing?.openingBalanceMinor ?? 0;
    if (_opening.text.isEmpty && opening > 0) {
      _opening.text = Formatters.of(context).groupDigits(opening);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _opening.dispose();
    super.dispose();
  }

  int get _openingMinor =>
      int.tryParse(_opening.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  Future<void> _save() async {
    setState(() => _submitted = true);
    if (validateAccountName(_name.text) != null || _busy) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final account = Account(
      id: widget.existing?.id ?? _uuid.v4(),
      name: _name.text.trim(),
      type: _type,
      openingBalanceMinor: _openingMinor,
    );
    setState(() => _busy = true);
    try {
      final notifier = ref.read(ledgerProvider.notifier);
      if (_isEditing) {
        await notifier.updateAccount(account);
      } else {
        await notifier.createAccount(account);
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.savedMessage)));
    } on LedgerException catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            e.failure == LedgerFailure.inUse
                ? l10n.openingBalanceLocked
                : l10n.saveFailed,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final fmt = Formatters.of(context);
    final locked =
        _isEditing &&
        accountInUse(widget.existing!.id, ref.watch(transactionsProvider));
    final nameError = _submitted
        ? switch (validateAccountName(_name.text)) {
            NameError.empty => l10n.errorNameRequired,
            NameError.tooLong => l10n.errorNameTooLong,
            _ => null,
          }
        : null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.cancel,
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(_isEditing ? l10n.editAccount : l10n.addAccount),
        actions: [
          TextButton(onPressed: _busy ? null : _save, child: Text(l10n.save)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          TextField(
            controller: _name,
            autofocus: !_isEditing,
            maxLength: maxAccountNameLength,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: l10n.accountNameLabel,
              hintText: l10n.accountNameHint,
              errorText: nameError,
              counterText: '',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.accountTypeLabel,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<AccountType>(
            showSelectedIcon: false,
            segments: [
              for (final t in AccountType.values)
                ButtonSegment(
                  value: t,
                  icon: Icon(t.icon),
                  label: Text(t.label(l10n)),
                ),
            ],
            selected: {_type},
            onSelectionChanged: (v) => setState(() => _type = v.first),
          ),
          const SizedBox(height: AppSpacing.xl),
          TextField(
            controller: _opening,
            enabled: !locked,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(13),
              TextInputFormatter.withFunction((old, value) {
                if (value.text.isEmpty) return value;
                final text = fmt.groupDigits(int.parse(value.text));
                return TextEditingValue(
                  text: text,
                  selection: TextSelection.collapsed(offset: text.length),
                );
              }),
            ],
            decoration: InputDecoration(
              labelText: l10n.openingBalanceLabel,
              hintText: '0',
              suffixText: '₫',
              helperText: locked
                  ? l10n.openingBalanceLocked
                  : l10n.openingBalanceHelp,
              helperMaxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
