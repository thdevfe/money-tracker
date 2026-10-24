/// Supabase connection, passed at build time:
///
///   flutter run --dart-define-from-file=config/supabase.json
///
/// When either value is missing the app runs in demo mode with sample data
/// kept in memory.
class BackendConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');

  /// The public "publishable" (or legacy "anon") key. Never the secret or
  /// service_role key.
  static const publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;
}
