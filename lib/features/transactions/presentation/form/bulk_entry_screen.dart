import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/formatting/formatters.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/bulk_entry_parser.dart';
import '../../domain/ledger.dart';
import '../../domain/ledger_repository.dart';
import '../../domain/models.dart';
import '../../providers/transactions_provider.dart';
import '../category_presentation.dart';
import '../widgets/transaction_list_item.dart';
import 'widgets/account_picker_sheet.dart';
import 'widgets/day_picker_sheet.dart';
import 'widgets/picker_chip.dart';

/// Type or paste a list, one transaction per line ("cà phê 35k"). Lines are
/// parsed live and saved together on one day and account. Pops with the
/// number of transactions saved.
class BulkEntryScreen extends ConsumerStatefulWidget {
  final DateTime? initialDate;

  const BulkEntryScreen({super.key, this.initialDate});

  @override
  ConsumerState<BulkEntryScreen> createState() => _BulkEntryScreenState();
}

class _BulkEntryScreenState extends ConsumerState<BulkEntryScreen> {
  static const _uuid = Uuid();

  final _controller = TextEditingController();
  late DateTime _day;
  late String _accountId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final today = dateOnly(ref.read(clockProvider)());
    _day = dateOnly(widget.initialDate ?? today);
    final accounts = ref.read(accountsProvider);
    _accountId =
        accounts.where((a) => a.type == AccountType.cash).firstOrNull?.id ??
        accounts.firstOrNull?.id ??
        '';
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<BulkEntryLine> get _lines => parseBulkEntry(_controller.text);

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) return;
    final current = _controller.text.trimRight();
    _controller.text = current.isEmpty ? text : '$current\n$text';
  }

  Future<void> _pickDay() async {
    final picked = await showDayPicker(
      context,
      initial: _day,
      today: dateOnly(ref.read(clockProvider)()),
    );
    if (picked != null) setState(() => _day = picked);
  }

  Future<void> _pickAccount() async {
    final id = await showAccountPicker(
      context,
      title: AppLocalizations.of(context).accountLabel,
      accounts: ref.read(accountsProvider),
      balances: ref.read(accountBalancesProvider),
      selectedId: _accountId,
    );
    if (id != null) setState(() => _accountId = id);
  }

  Future<void> _save() async {
    final valid = _lines.where((l) => l.isValid).toList();
    if (valid.isEmpty || _saving) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final now = ref.read(clockProvider)();
    final notifier = ref.read(ledgerProvider.notifier);

    var saved = 0;
    try {
      for (final line in valid) {
        await notifier.save(
          MoneyTransaction(
            id: _uuid.v4(),
            type: line.type,
            amountMinor: line.amountMinor!,
            // Keeps the lines in order within the day.
            occurredAt: DateTime(
              _day.year,
              _day.month,
              _day.day,
              now.hour,
              now.minute,
            ).add(Duration(seconds: saved)),
            accountId: _accountId,
            category: Category.system(line.category),
            note: line.note.isEmpty ? null : line.note,
          ),
        );
        saved++;
      }
    } on LedgerException {
      if (!mounted) return;
      // Leave only what wasn't saved, so a retry doesn't duplicate.
      final remaining = valid.skip(saved).map((l) => l.raw).join('\n');
      _controller.text = remaining;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(l10n.saveFailed)));
      return;
    }
    if (mounted) Navigator.of(context).pop(saved);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fmt = Formatters.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final accounts = ref.watch(accountByIdProvider);
    final lines = _lines;
    final validCount = lines.where((l) => l.isValid).length;
    final today = dateOnly(ref.watch(clockProvider)());

    return Scaffold(
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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: theme.colorScheme.onSurface.withValues(
                          alpha: 0.08,
                        ),
                        foregroundColor: theme.colorScheme.onSurface,
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  Text(l10n.bulkEntry, style: theme.textTheme.titleMedium),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                PickerChip(
                  key: const ValueKey('bulk_day'),
                  icon: Icons.calendar_month_rounded,
                  label: isSameDay(_day, today)
                      ? l10n.today
                      : fmt.dayMonth(_day),
                  onTap: _pickDay,
                ),
                PickerChip(
                  key: const ValueKey('bulk_account'),
                  icon: accounts[_accountId]?.type.icon,
                  label: accounts[_accountId]?.name ?? '',
                  onTap: _pickAccount,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.elevatedSurface,
                  borderRadius: BorderRadius.circular(AppRadii.card),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    TextField(
                      key: const ValueKey('bulk_text'),
                      controller: _controller,
                      autofocus: true,
                      minLines: 5,
                      maxLines: 8,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: l10n.bulkHint,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: const EdgeInsets.all(AppSpacing.lg),
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        0,
                        AppSpacing.md,
                        AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          FilledButton.tonalIcon(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(0, 36),
                            ),
                            onPressed: _paste,
                            icon: const Icon(Icons.content_paste_rounded),
                            label: Text(l10n.paste),
                          ),
                          for (final example in const [
                            '35k = 35.000',
                            '1tr2 = 1.200.000',
                            '+ = thu',
                          ])
                            Padding(
                              padding: const EdgeInsets.only(
                                left: AppSpacing.sm,
                              ),
                              child: Chip(
                                visualDensity: VisualDensity.compact,
                                label: Text(
                                  example == '+ = thu'
                                      ? '+ = ${l10n.typeIncome}'
                                      : example,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: lines.isEmpty
                  ? _EmptyState(
                      title: l10n.bulkEmptyTitle,
                      body: l10n.bulkEmptyBody,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.lg,
                        AppSpacing.md,
                      ),
                      itemCount: lines.length,
                      itemBuilder: (context, i) => _LinePreview(line: lines[i]),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: FilledButton(
                key: const ValueKey('bulk_save'),
                onPressed: validCount == 0 || _saving ? null : _save,
                child: Text(l10n.bulkSave(validCount)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinePreview extends StatelessWidget {
  final BulkEntryLine line;

  const _LinePreview({required this.line});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fmt = Formatters.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final category = line.category;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: line.isValid
                  ? category.tint
                  : theme.colorScheme.error.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              line.isValid ? category.icon : Icons.error_outline_rounded,
              color: line.isValid ? Colors.white : theme.colorScheme.error,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.note.isEmpty ? category.label(l10n) : line.note,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  line.isValid ? category.label(l10n) : l10n.bulkNoAmount,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: line.isValid
                        ? colors.textSecondary
                        : theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
          if (line.isValid)
            Text(
              fmt.signedMoney(line.type, line.amountMinor!),
              style: theme.textTheme.titleSmall?.copyWith(
                color: amountColor(context, line.type),
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String body;

  const _EmptyState({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        children: [
          Icon(
            Icons.playlist_add_rounded,
            size: 56,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
