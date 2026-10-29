import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatting/formatters.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../transactions/domain/ledger.dart';
import '../../transactions/domain/models.dart';
import '../../transactions/presentation/category_presentation.dart';
import '../../transactions/providers/transactions_provider.dart';
import '../domain/budget.dart';
import '../providers/budgets_provider.dart';
import 'budget_form_screen.dart';

Future<void> openBudgetForm(
  BuildContext context, {
  Budget? existing,
  Budget? template,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => BudgetFormScreen(existing: existing, template: template),
      fullscreenDialog: true,
    ),
  );
}

/// Monthly budgets with progress for the current period, and templates to
/// start from.
class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final budgets = ref.watch(budgetsProvider);
    final transactions = ref.watch(transactionsProvider);

    // The two categories with the most spending, for the template.
    final top = expenseByCategory(transactions).take(2).toList();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => ref.read(budgetsProvider.notifier).load(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.navClearance,
            ),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.budgetsTitle,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          l10n.budgetsSubtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filled(
                    tooltip: l10n.addBudget,
                    icon: const Icon(Icons.add_rounded),
                    onPressed: () => openBudgetForm(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              budgets.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, _) => Text(
                  l10n.budgetsLoadFailed,
                  style: TextStyle(color: colors.textSecondary),
                ),
                data: (items) => items.isEmpty
                    ? Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xxl),
                          child: Column(
                            children: [
                              Icon(
                                Icons.credit_card_rounded,
                                size: 48,
                                color: colors.textSecondary,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                l10n.noBudgetsTitle,
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                l10n.noBudgetsMessage,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: colors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          for (final b in items) ...[
                            _BudgetCard(budget: b),
                            const SizedBox(height: AppSpacing.md),
                          ],
                        ],
                      ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                l10n.startFromTemplate,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _TemplateTile(
                key: const ValueKey('template_monthly'),
                icon: Icons.credit_card_rounded,
                color: const Color(0xFF3B82F6),
                title: l10n.templateMonthlyTitle,
                body: l10n.templateMonthlyBody,
                onTap: () => openBudgetForm(
                  context,
                  template: Budget(
                    id: '',
                    name: l10n.templateMonthlyTitle,
                    limitMinor: 0,
                  ),
                ),
              ),
              if (top.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                _TemplateTile(
                  key: const ValueKey('template_top'),
                  icon: Icons.shopping_cart_rounded,
                  color: const Color(0xFFF59E0B),
                  title: l10n.templateTopTitle,
                  body: l10n.templateTopBody(
                    top.map((t) => t.category.label(l10n)).join(', '),
                  ),
                  onTap: () => openBudgetForm(
                    context,
                    template: Budget(
                      id: '',
                      name: top.map((t) => t.category.label(l10n)).join(', '),
                      limitMinor: 0,
                      categoryIds: [for (final t in top) t.category.id],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetCard extends ConsumerWidget {
  final Budget budget;

  const _BudgetCard({required this.budget});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final fmt = Formatters.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final (start, end) = ref.watch(budgetPeriodProvider);
    final today = dateOnly(ref.watch(clockProvider)());
    final spent = budget.spentMinor(
      ref.watch(transactionsProvider),
      start: start,
      end: end,
    );
    final ratio = spent / budget.limitMinor;
    final left = budget.limitMinor - spent;
    final daysLeft = end.difference(today).inDays - 1;
    final barColor = ratio >= 1
        ? colors.expense
        : ratio >= 0.8
        ? const Color(0xFFF59E0B)
        : colors.income;
    final categories = [
      ...Category.systemFor(TransactionType.expense),
      ...ref.watch(ledgerProvider.select((s) => s.customCategories)),
    ].where((c) => budget.categoryIds.contains(c.id)).toList();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openBudgetForm(context, existing: budget),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      budget.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    l10n.budgetDaysLeft(daysLeft < 0 ? 0 : daysLeft),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: budget.coversAll
                    ? [_Tag(label: l10n.budgetAllSpending)]
                    : [
                        for (final c in categories)
                          _Tag(
                            label: c.label(l10n),
                            icon: c.icon,
                            color: c.tint,
                          ),
                      ],
              ),
              const SizedBox(height: AppSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: ratio.clamp(0, 1).toDouble(),
                  minHeight: 10,
                  color: barColor,
                  backgroundColor: colors.border,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.budgetSpentOf(
                        fmt.money(spent),
                        fmt.money(budget.limitMinor),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    left >= 0
                        ? l10n.budgetLeft(fmt.money(left))
                        : l10n.budgetOver(fmt.money(-left)),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: left >= 0 ? colors.income : colors.expense,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;

  const _Tag({required this.label, this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final tint = color ?? colors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: tint),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: tint,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplateTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final VoidCallback onTap;

  const _TemplateTile({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.18),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(body, style: TextStyle(color: colors.textSecondary)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
