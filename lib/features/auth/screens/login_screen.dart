import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/app_notification_host_widget.dart';
import '../../../shared/widgets/auth_text_field_widget.dart';
import '../data/auth_api_service.dart';
import '../data/auth_session.dart';
import '../theme/auth_sizes.dart';
import '../utils/auth_validators.dart';
import '../widgets/auth_form_layout_widget.dart';
import '../widgets/auth_primary_button_widget.dart';
import '../widgets/auth_separator_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({required this.authSession, super.key});

  final AuthSession authSession;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _hasLoginError = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _hasLoginError = false;
      _isSubmitting = true;
    });

    try {
      // Pas de navigation ici : le routeur redirige vers l'accueil dès que la session s'ouvre.
      await widget.authSession.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on AuthApiException catch (error) {
      if (!mounted) {
        return;
      }
      if (error.statusCode == 401) {
        setState(() {
          _hasLoginError = true;
        });
      } else {
        AppNotificationHost.of(context).showError(error.message);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.landing);
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompactHeight = MediaQuery.sizeOf(context).height < 700;

    return AuthFormLayoutWidget(
      title: 'Connectez-vous à votre compte Green’Hub',
      subtitle: 'Heureux de vous revoir !',
      formKey: _formKey,
      onBack: _goBack,
      physics: const AuthFormNeverScrollablePhysics(),
      titleTopSpacing: isCompactHeight ? 0 : AuthSizes.formTitleTopSpacing,
      formTopSpacing: isCompactHeight ? 0 : AuthSizes.loginFormTopSpacing,
      footer: <Widget>[
        if (_hasLoginError) ...<Widget>[
          Text(
            'Email ou mot de passe est incorrect',
            textAlign: TextAlign.center,
            style: AppTextStyles.formFeedback,
          ),
          SizedBox(height: AppSpacing.sm),
        ],
        SizedBox(height: isCompactHeight ? AppSpacing.xxs : AppSpacing.sm),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: AuthPrimaryButtonWidget(
            label: 'Connexion',
            isLoading: _isSubmitting,
            onPressed: _isSubmitting ? null : _submit,
          ),
        ),
        SizedBox(height: isCompactHeight ? AppSpacing.xs : AppSpacing.lg),
        const AuthSeparatorWidget(),
        SizedBox(height: isCompactHeight ? AppSpacing.xs : AppSpacing.lg),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Text('Pas encore de compte ? ', style: AppTextStyles.formPrompt),
            TextButton(
              onPressed: () => context.go(AppRoutes.register),
              child: Text(
                'Inscrivez-vous',
                style: AppTextStyles.formPromptAction,
              ),
            ),
          ],
        ),
      ],
      children: <Widget>[
        AuthTextFieldWidget(
          label: 'Email',
          hint: 'Email*',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          hasError: _hasLoginError,
          validator: validateEmail,
        ),
        SizedBox(
          height: isCompactHeight ? AppSpacing.xxs : AppSpacing.fieldGap,
        ),
        AuthTextFieldWidget(
          label: 'Mot de passe',
          hint: '•••••••',
          controller: _passwordController,
          obscureText: true,
          hasError: _hasLoginError,
          validator: validatePassword,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => context.push(AppRoutes.forgotPassword),
            style: isCompactHeight
                ? TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )
                : null,
            child: Text('Mot de passe oublié ?', style: AppTextStyles.formLink),
          ),
        ),
      ],
    );
  }
}
