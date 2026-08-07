import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/auth_text_field_widget.dart';
import '../theme/auth_sizes.dart';
import '../widgets/auth_primary_button_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Connexion simulée avec succès.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthFormScaffold(
      title: 'Connexion',
      formKey: _formKey,
      fields: <Widget>[
        AuthTextFieldWidget(
          label: 'Adresse e-mail',
          hint: 'vous@exemple.fr',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          validator: validateEmail,
        ),
        SizedBox(height: AppSpacing.md),
        AuthTextFieldWidget(
          label: 'Mot de passe',
          hint: 'Votre mot de passe',
          controller: _passwordController,
          obscureText: true,
          validator: validatePassword,
        ),
      ],
      actionLabel: 'Se connecter',
      onSubmit: _submit,
      prompt: 'Pas encore de compte ?',
      promptAction: 'Inscription',
      onPromptPressed: () => context.go(AppRoutes.register),
    );
  }
}

String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Veuillez renseigner votre adresse e-mail.';
  }
  if (!value.contains('@')) {
    return 'Veuillez saisir une adresse e-mail valide.';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Veuillez renseigner votre mot de passe.';
  }
  return null;
}

class AuthFormScaffold extends StatelessWidget {
  const AuthFormScaffold({
    required this.title,
    required this.formKey,
    required this.fields,
    required this.actionLabel,
    required this.onSubmit,
    required this.prompt,
    required this.promptAction,
    required this.onPromptPressed,
    super.key,
  });

  final String title;
  final GlobalKey<FormState> formKey;
  final List<Widget> fields;
  final String actionLabel;
  final VoidCallback onSubmit;
  final String prompt;
  final String promptAction;
  final VoidCallback onPromptPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        foregroundColor: AppColors.o900,
        surfaceTintColor: AppColors.transparent,
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: AuthSizes.contentMaxWidthMobile,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(title, style: AppTextStyles.title),
                    SizedBox(height: AppSpacing.xl),
                    ...fields,
                    SizedBox(height: AppSpacing.xxl),
                    AuthPrimaryButtonWidget(
                      label: actionLabel,
                      onPressed: onSubmit,
                    ),
                    SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(prompt, style: AppTextStyles.bodySmall),
                        TextButton(
                          onPressed: onPromptPressed,
                          child: Text(promptAction),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
