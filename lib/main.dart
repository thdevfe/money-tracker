import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/config/backend_config.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/budgets/data/supabase_budget_repository.dart';
import 'features/budgets/providers/budgets_provider.dart';
import 'features/deposits/data/supabase_deposit_repository.dart';
import 'features/deposits/providers/deposits_provider.dart';
import 'features/settings/data/shared_preference_store.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/transactions/data/supabase_ledger_repository.dart';
import 'features/transactions/providers/transactions_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  final overrides = <Override>[
    preferenceStoreProvider.overrideWithValue(
      SharedPreferenceStore(preferences),
    ),
  ];

  // Without Supabase settings the app runs in demo mode with sample data.
  if (BackendConfig.isConfigured) {
    final supabase = await Supabase.initialize(
      url: BackendConfig.url,
      publishableKey: BackendConfig.publishableKey,
    );
    overrides.addAll([
      authServiceProvider.overrideWithValue(AuthService(supabase.client.auth)),
      ledgerRepositoryProvider.overrideWithValue(
        SupabaseLedgerRepository(supabase.client),
      ),
      depositRepositoryProvider.overrideWithValue(
        SupabaseDepositRepository(supabase.client),
      ),
      budgetRepositoryProvider.overrideWithValue(
        SupabaseBudgetRepository(supabase.client),
      ),
    ]);
  }

  runApp(ProviderScope(overrides: overrides, child: const MoneyTrackerApp()));
}
