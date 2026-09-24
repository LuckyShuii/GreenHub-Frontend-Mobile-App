import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/widgets/auth_text_field_widget.dart';
import '../theme/auth_sizes.dart';
import '../utils/auth_validators.dart';
import '../widgets/auth_form_layout_widget.dart';
import '../widgets/auth_primary_button_widget.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.login);
  }

  void _submit() {
    _formKey.currentState?.validate();
  }

  @override
  Widget build(BuildContext context) {
    return AuthFormLayoutWidget(
      title: 'Mot de passe oublié ?',
      subtitle:
          'Veuillez saisir votre email de connexion pour recevoir un lien afin de réinitialiser votre mot de passe',
      formKey: _formKey,
      onBack: _goBack,
      physics: const AuthFormNeverScrollablePhysics(),
      titleTopSpacing: AuthSizes.formTitleTopSpacing,
      footer: <Widget>[
        SizedBox(height: AppSpacing.xxxl),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: AuthPrimaryButtonWidget(
            label: 'Recevoir un lien',
            onPressed: _submit,
          ),
        ),
      ],
      children: <Widget>[
        SizedBox(height: AppSpacing.xxl),
        AuthTextFieldWidget(
          label: 'Email',
          hint: 'Email*',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          validator: validateEmail,
        ),
      ],
    );
  }
}
