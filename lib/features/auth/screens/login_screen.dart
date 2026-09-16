import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/auth_text_field_widget.dart';
import '../theme/auth_sizes.dart';
import '../utils/auth_validators.dart';
import '../widgets/auth_form_layout_widget.dart';
import '../widgets/auth_primary_button_widget.dart';
import '../widgets/auth_separator_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _hasLoginError = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _hasLoginError = true;
    });
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
    return AuthFormLayoutWidget(
      title: 'Connectez-vous à votre compte Green’Hub',
      subtitle: 'Heureux de vous revoir !',
      formKey: _formKey,
      onBack: _goBack,
      titleTopSpacing: AuthSizes.formTitleTopSpacing,
      formTopSpacing: AuthSizes.loginFormTopSpacing,
      footer: <Widget>[
        if (_hasLoginError) ...<Widget>[
          Text(
            'Email ou mot de passe est incorrect',
            textAlign: TextAlign.center,
            style: AppTextStyles.formFeedback,
          ),
          SizedBox(height: AppSpacing.sm),
        ],
        SizedBox(height: AppSpacing.sm),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: AuthPrimaryButtonWidget(
            label: 'Connexion',
            onPressed: _submit,
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        const AuthSeparatorWidget(),
        SizedBox(height: AppSpacing.lg),
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
        SizedBox(height: AppSpacing.fieldGap),
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
            child: Text('Mot de passe oublié ?', style: AppTextStyles.formLink),
          ),
        ),
      ],
    );
  }
}
