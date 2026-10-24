import 'package:flutter/material.dart';

import '../../../core/widgets/empty_state_view.dart';
import '../../../l10n/app_localizations.dart';

/// Placeholder until the reports milestone.
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navReports)),
      body: Center(
        child: EmptyStateView(
          icon: Icons.pie_chart_outline_rounded,
          title: l10n.reportsComingTitle,
          message: l10n.reportsComingMessage,
        ),
      ),
    );
  }
}
