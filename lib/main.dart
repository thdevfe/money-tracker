import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/config/backend_config.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/transactions/data/supabase_ledger_repository.dart';
import 'features/transactions/providers/transactions_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Without Supabase settings the app runs in demo mode with sample data.
  final overrides = <Override>[];
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
    ]);
  }

  runApp(ProviderScope(overrides: overrides, child: const MoneyTrackerApp()));
}
