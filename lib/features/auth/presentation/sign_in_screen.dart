import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

/// Email + password sign-in and sign-up.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _signUp = false;
  bool _busy = false;
  bool _obscure = true;
  String? _message;
  bool _messageIsError = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String _failureText(AppLocalizations l10n, AuthFailure f) => switch (f) {
    AuthFailure.invalidCredentials => l10n.authInvalidCredentials,
    AuthFailure.emailNotConfirmed => l10n.authEmailNotConfirmed,
    AuthFailure.userExists => l10n.authUserExists,
    AuthFailure.weakPassword => l10n.authWeakPassword,
    AuthFailure.network => l10n.authNetwork,
    AuthFailure.unknown => l10n.authUnknown,
  };

  Future<void> _submit() async {
    if (_busy || !_formKey.currentState!.validate()) return;
    final auth = ref.read(authServiceProvider);
    if (auth == null) return;
    final l10n = AppLocalizations.of(context);
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      if (_signUp) {
        final needsConfirmation = await auth.signUp(
          _email.text,
          _password.text,
        );
        if (needsConfirmation && mounted) {
          setState(() {
            _signUp = false;
            _message = l10n.confirmEmailSent;
            _messageIsError = false;
          });
        }
      } else {
        await auth.signIn(_email.text, _password.text);
      }
      // A successful sign-in switches the app to the main shell.
    } on AuthServiceException catch (e) {
      if (mounted) {
        setState(() {
          _message = _failureText(l10n, e.failure);
          _messageIsError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Icon(
                          Icons.photo_camera_back_rounded,
                          size: 36,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        l10n.appTitle,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.signInSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: l10n.emailLabel,
                          prefixIcon: const Icon(Icons.mail_outline_rounded),
                        ),
                        validator: (v) {
                          final text = v?.trim() ?? '';
                          return RegExp(
                                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                              ).hasMatch(text)
                              ? null
                              : l10n.errorEmailInvalid;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _password,
                        obscureText: _obscure,
                        autofillHints: [
                          _signUp
                              ? AutofillHints.newPassword
                              : AutofillHints.password,
                        ],
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: l10n.passwordLabel,
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            tooltip: _obscure
                                ? l10n.showPassword
                                : l10n.hidePassword,
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) => (v ?? '').length < 6
                            ? l10n.errorPasswordShort
                            : null,
                      ),
                      if (_message != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          _message!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _messageIsError
                                ? theme.colorScheme.error
                                : theme.colorScheme.primary,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      FilledButton(
                        onPressed: _busy ? null : _submit,
                        child: _busy
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                _signUp ? l10n.signUpAction : l10n.signInAction,
                              ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(
                        onPressed: _busy
                            ? null
                            : () => setState(() {
                                _signUp = !_signUp;
                                _message = null;
                              }),
                        child: Text(
                          _signUp ? l10n.switchToSignIn : l10n.switchToSignUp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
