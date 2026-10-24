import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthFailure {
  invalidCredentials,
  emailNotConfirmed,
  userExists,
  weakPassword,
  network,
  unknown,
}

class AuthServiceException implements Exception {
  final AuthFailure failure;

  const AuthServiceException(this.failure);
}

/// Email + password sign-in on Supabase Auth.
class AuthService {
  final GoTrueClient _auth;

  AuthService(this._auth);

  String? get currentUserId => _auth.currentUser?.id;

  String? get currentEmail => _auth.currentUser?.email;

  Stream<String?> get userIdChanges =>
      _auth.onAuthStateChange.map((state) => state.session?.user.id);

  Future<void> signIn(String email, String password) => _guard(
    () => _auth.signInWithPassword(email: email.trim(), password: password),
  );

  /// Returns true when the account still needs email confirmation.
  Future<bool> signUp(String email, String password) async {
    final response = await _guard(
      () => _auth.signUp(
        email: email.trim(),
        password: password,
        // On web, the confirmation link returns to this site.
        emailRedirectTo: kIsWeb ? Uri.base.origin : null,
      ),
    );
    return response.session == null;
  }

  Future<void> signOut() => _auth.signOut();

  static Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AuthException catch (e) {
      throw AuthServiceException(switch (e.code) {
        'invalid_credentials' => AuthFailure.invalidCredentials,
        'email_not_confirmed' => AuthFailure.emailNotConfirmed,
        'user_already_exists' || 'email_exists' => AuthFailure.userExists,
        'weak_password' => AuthFailure.weakPassword,
        _ => AuthFailure.unknown,
      });
    } catch (_) {
      throw const AuthServiceException(AuthFailure.network);
    }
  }
}

/// Null in demo mode (no backend configured).
final authServiceProvider = Provider<AuthService?>((ref) => null);

/// The signed-in user's id; "demo" in demo mode; null when signed out.
class CurrentUserNotifier extends StateNotifier<String?> {
  StreamSubscription<String?>? _subscription;

  CurrentUserNotifier(AuthService? auth)
    : super(auth == null ? 'demo' : auth.currentUserId) {
    _subscription = auth?.userIdChanges.listen((id) => state = id);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final currentUserIdProvider =
    StateNotifierProvider<CurrentUserNotifier, String?>(
      (ref) => CurrentUserNotifier(ref.watch(authServiceProvider)),
    );
