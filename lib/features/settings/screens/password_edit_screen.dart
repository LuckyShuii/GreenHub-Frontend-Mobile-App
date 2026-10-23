import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../features/auth/data/auth_api_service.dart';
import '../../../features/auth/data/auth_session.dart';
import '../../../features/auth/data/models/change_password_request.dart';
import '../../../features/auth/utils/password_policy.dart';
import '../../../features/auth/widgets/auth_primary_button_widget.dart';
import '../../../features/auth/widgets/password_composition_widget.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/widgets/app_notification_host_widget.dart';
import '../../../shared/widgets/auth_text_field_widget.dart';
import '../theme/settings_sizes.dart';
import '../widgets/settings_page_header_widget.dart';

class PasswordEditScreen extends StatefulWidget {
  const PasswordEditScreen({required this.authSession, super.key});

  final AuthSession authSession;

  @override
  State<PasswordEditScreen> createState() => _PasswordEditScreenState();
}

class _PasswordEditScreenState extends State<PasswordEditScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmationController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_refresh);
    _confirmationController.addListener(_refresh);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_refresh);
    _confirmationController.removeListener(_refresh);
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  bool get _canSubmit {
    final String password = _passwordController.text;
    return PasswordPolicy(password).isValid &&
        _confirmationController.text == password &&
        _confirmationController.text.isNotEmpty;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await widget.authSession.changePassword(
        ChangePasswordRequest(newPassword: _passwordController.text),
      );
      if (mounted) {
        AppNotificationHost.of(
          context,
        ).showSuccess('Votre mot de passe a été modifié.');
        context.pop();
      }
    } on AuthApiException catch (error) {
      if (mounted) {
        AppNotificationHost.of(context).showError(error.message);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMismatch =
        _confirmationController.text.isNotEmpty &&
        _confirmationController.text != _passwordController.text;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            SettingsSizes.pageInset,
            SettingsSizes.pageTopInset,
            SettingsSizes.pageInset,
            AppSpacing.md,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                SettingsPageHeaderWidget(
                  title: 'Profil',
                  onBack: () => _goBack(context),
                ),
                SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        PasswordCompositionWidget(
                          controller: _passwordController,
                          password: _passwordController.text,
                          label: 'Nouveau mot de passe',
                          fieldKey: const Key('profile-new-password-field'),
                          validator: _validatePassword,
                        ),
                        SizedBox(height: AppSpacing.xl),
                        AuthTextFieldWidget(
                          label: 'Confirmation mot de passe',
                          hint: '•••••••',
                          controller: _confirmationController,
                          obscureText: true,
                          hasError: isMismatch,
                          errorText: isMismatch
                              ? 'Les mots de passe ne correspondent pas.'
                              : null,
                          autovalidate: false,
                          validator: _validateConfirmation,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SettingsSizes.destructiveButtonInset,
                  ),
                  child: AuthPrimaryButtonWidget(
                    label: 'Changer votre mot de passe',
                    isLoading: _isSubmitting,
                    onPressed: _canSubmit && !_isSubmitting ? _submit : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _goBack(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(AppRoutes.profile);
  }
}

String? _validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Veuillez renseigner votre mot de passe.';
  }
  if (!PasswordPolicy(value).isValid) {
    return 'Le mot de passe ne respecte pas les critères requis.';
  }
  return null;
}

String? _validateConfirmation(String? value) {
  if (value == null || value.isEmpty) {
    return 'Veuillez confirmer votre mot de passe.';
  }
  return null;
}
