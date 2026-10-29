import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/formatting/formatters.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../transactions/domain/ledger.dart';
import '../../transactions/domain/models.dart';
import '../../transactions/presentation/form/widgets/day_picker_sheet.dart';
import '../../transactions/providers/transactions_provider.dart';
import '../domain/term_deposit.dart';
import '../providers/deposits_provider.dart';

/// Add or edit a term deposit: bank, amount, yearly rate, term and start.
class DepositFormScreen extends ConsumerStatefulWidget {
  final TermDeposit? existing;

  const DepositFormScreen({super.key, this.existing});

  @override
  ConsumerState<DepositFormScreen> createState() => _DepositFormScreenState();
}

class _DepositFormScreenState extends ConsumerState<DepositFormScreen> {
  static const _uuid = Uuid();
  static const _terms = [1, 3, 6, 9, 12, 18, 24, 36];

  late final _bank = TextEditingController(text: widget.existing?.bankName);
  final _principal = TextEditingController();
  final _rate = TextEditingController();
  late int _termMonths = widget.existing?.termMonths ?? 6;
  late DateTime _start =
      widget.existing?.startDate ?? dateOnly(ref.read(clockProvider)());
  bool _submitted = false;
  bool _busy = false;

  bool get _isEditing => widget.existing != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final fmt = Formatters.of(context);
    final existing = widget.existing;
    if (existing != null && _principal.text.isEmpty) {
      _principal.text = fmt.groupDigits(existing.principalMinor);
      _rate.text = fmt.decimal(existing.ratePercent);
    }
  }

  @override
  void dispose() {
    _bank.dispose();
    _principal.dispose();
    _rate.dispose();
    super.dispose();
  }

  int get _principalMinor =>
      int.tryParse(_principal.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  /// Accepts "5,5" or "5.5"; null when not a rate between 0 and 100.
  int? get _rateBasisPoints {
    final value = double.tryParse(_rate.text.trim().replaceAll(',', '.'));
    if (value == null || value < 0 || value > 100) return null;
    return (value * 100).round();
  }

  Future<void> _pickStart() async {
    final picked = await showDayPicker(
      context,
      initial: _start,
      today: dateOnly(ref.read(clockProvider)()),
    );
    if (picked != null) setState(() => _start = picked);
  }

  Future<void> _save() async {
    setState(() => _submitted = true);
    final rate = _rateBasisPoints;
    if (_bank.text.trim().isEmpty ||
        _principalMinor <= 0 ||
        rate == null ||
        _busy) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await ref
          .read(depositsProvider.notifier)
          .save(
            TermDeposit(
              id: widget.existing?.id ?? _uuid.v4(),
              bankName: _bank.text.trim(),
              principalMinor: _principalMinor,
              rateBasisPoints: rate,
              startDate: _start,
              termMonths: _termMonths,
            ),
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.savedMessage)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger.showSnackBar(SnackBar(content: Text(l10n.saveFailed)));
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteDepositTitle),
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
      await ref.read(depositsProvider.notifier).delete(widget.existing!);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.deleteFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final fmt = Formatters.of(context);
    final rate = _rateBasisPoints;
    final preview = rate == null || _principalMinor <= 0
        ? null
        : TermDeposit(
            id: '',
            bankName: '',
            principalMinor: _principalMinor,
            rateBasisPoints: rate,
            startDate: _start,
            termMonths: _termMonths,
          );

    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          color: colors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.cancel,
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(_isEditing ? l10n.editDeposit : l10n.addDeposit),
        actions: [
          if (_isEditing)
            IconButton(
              tooltip: l10n.delete,
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _busy ? null : _delete,
            ),
          TextButton(
            key: const ValueKey('deposit_save'),
            onPressed: _busy ? null : _save,
            child: Text(l10n.save),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          TextField(
            key: const ValueKey('deposit_bank'),
            controller: _bank,
            autofocus: !_isEditing,
            maxLength: 60,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: l10n.depositBank,
              hintText: l10n.depositBankHint,
              counterText: '',
              prefixIcon: const Icon(Icons.account_balance_rounded),
              errorText: _submitted && _bank.text.trim().isEmpty
                  ? l10n.errorBankRequired
                  : null,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            key: const ValueKey('deposit_principal'),
            controller: _principal,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
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
              labelText: l10n.depositPrincipal,
              hintText: '0',
              suffixText: '₫',
              errorText: _submitted && _principalMinor <= 0
                  ? l10n.errorAmountPositive
                  : null,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            key: const ValueKey('deposit_rate'),
            controller: _rate,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              LengthLimitingTextInputFormatter(6),
            ],
            decoration: InputDecoration(
              labelText: l10n.depositRate,
              hintText: '5,5',
              suffixText: '%',
              errorText: _submitted && rate == null
                  ? l10n.errorRateInvalid
                  : null,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          label(l10n.depositTerm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final months in _terms)
                ChoiceChip(
                  label: Text(l10n.depositTermMonths(months)),
                  selected: _termMonths == months,
                  onSelected: (_) => setState(() => _termMonths = months),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          label(l10n.depositStart),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_month_rounded),
            title: Text(fmt.fullDate(_start)),
            trailing: const Icon(Icons.expand_more_rounded),
            onTap: _pickStart,
          ),
          if (preview != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.depositMaturity(fmt.fullDate(preview.maturityDate)),
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${l10n.depositInterestTotal}: '
                      '${fmt.signedMoney(TransactionType.income, preview.interestAtMaturityMinor)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.income,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
