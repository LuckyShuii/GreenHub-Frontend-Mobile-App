import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/utils/no_overscroll_scroll_behavior.dart';
import '../../../shared/widgets/auth_text_field_widget.dart';
import '../data/auth_api_service.dart';
import '../data/models/register_request.dart';
import '../theme/auth_sizes.dart';
import '../utils/password_policy.dart';
import '../widgets/auth_back_button_widget.dart';
import '../widgets/auth_primary_button_widget.dart';
import '../widgets/password_composition_widget.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({this.authApiService, super.key});

  final AuthApiService? authApiService;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const String _passwordMismatchMessage =
      'Les mots de passes ne correspondent pas';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController =
      TextEditingController();
  late final AuthApiService _authApiService;
  bool _hasPasswordMismatch = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _authApiService = widget.authApiService ?? AuthApiService();
    _passwordController.addListener(_updatePasswordState);
    _passwordConfirmationController.addListener(_updatePasswordState);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _locationController.dispose();
    _passwordController.removeListener(_updatePasswordState);
    _passwordConfirmationController.removeListener(_updatePasswordState);
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final RegisterRequest request = RegisterRequest(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
      username: _usernameController.text,
      location: _locationController.text,
      password: _passwordController.text,
    );

    try {
      await _authApiService.register(request);
      if (!mounted) {
        return;
      }
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Inscription réussie'),
          content: const Text(
            'Votre compte a été créé. Vous pouvez maintenant vous connecter.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Continuer'),
            ),
          ],
        ),
      );
      if (mounted) {
        context.go(AppRoutes.login);
      }
    } on AuthApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
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

    context.go(AppRoutes.login);
  }

  void _updatePasswordState() {
    final bool hasPasswordMismatch =
        _passwordConfirmationController.text.isNotEmpty &&
        _passwordConfirmationController.text != _passwordController.text;

    setState(() {
      _hasPasswordMismatch = hasPasswordMismatch;
    });
  }

  bool get _canSubmit {
    final String password = _passwordController.text;
    final String confirmation = _passwordConfirmationController.text;

    return PasswordPolicy(password).isValid &&
        confirmation.isNotEmpty &&
        confirmation == password;
  }

  String? _validateRegistrationPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez renseigner votre mot de passe.';
    }
    if (!PasswordPolicy(value).isValid) {
      return 'Le mot de passe ne respecte pas les critères requis.';
    }
    return null;
  }

  String? _validatePasswordConfirmation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer votre mot de passe.';
    }
    if (value != _passwordController.text) {
      return _passwordMismatchMessage;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: AppColors.o50,
        systemNavigationBarColor: AppColors.o50,
      ),
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: AuthSizes.contentMaxWidthMobile,
              ),
              child: ScrollConfiguration(
                behavior: const NoOverscrollScrollBehavior(),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    AuthSizes.registerContentPadding,
                    AuthSizes.registerTopPadding,
                    AuthSizes.registerContentPadding,
                    AppSpacing.xl,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: AuthBackButtonWidget(onPressed: _goBack),
                        ),
                        SizedBox(height: AppSpacing.md),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AuthSizes.registerTitleInset,
                          ),
                          child: Text(
                            'Création de votre\ncompte Green’Hub',
                            style: AppTextStyles.formTitle,
                          ),
                        ),
                        SizedBox(height: AppSpacing.md),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                          ),
                          child: Text(
                            'Bienvenu dans l’écosystème !',
                            style: AppTextStyles.formSubtitle,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        AuthTextFieldWidget(
                          label: 'Prénom',
                          hint: 'Prénom*',
                          controller: _firstNameController,
                          keyboardType: TextInputType.name,
                          validator: _validateRequired,
                        ),
                        SizedBox(height: AppSpacing.fieldGap),
                        AuthTextFieldWidget(
                          label: 'Nom',
                          hint: 'Nom*',
                          controller: _lastNameController,
                          keyboardType: TextInputType.name,
                          validator: _validateRequired,
                        ),
                        SizedBox(height: AppSpacing.fieldGap),
                        AuthTextFieldWidget(
                          label: 'Email',
                          hint: 'Email*',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: validateEmail,
                        ),
                        SizedBox(height: AppSpacing.fieldGap),
                        AuthTextFieldWidget(
                          label: 'Pseudonyme',
                          hint: 'Pseudonyme*',
                          controller: _usernameController,
                          validator: _validateRequired,
                        ),
                        SizedBox(height: AppSpacing.fieldGap),
                        AuthTextFieldWidget(
                          label: 'Localisation',
                          hint: 'Localisation',
                          controller: _locationController,
                        ),
                        SizedBox(height: AppSpacing.fieldGap),
                        PasswordCompositionWidget(
                          controller: _passwordController,
                          password: _passwordController.text,
                          hasError: _hasPasswordMismatch,
                          validator: _validateRegistrationPassword,
                        ),
                        SizedBox(height: AppSpacing.fieldGap),
                        AuthTextFieldWidget(
                          key: const Key('register-password-confirmation'),
                          label: 'Confirmation du mot de passe',
                          hint: '•••••••',
                          controller: _passwordConfirmationController,
                          obscureText: true,
                          hasError: _hasPasswordMismatch,
                          autovalidate: false,
                          errorText: _hasPasswordMismatch
                              ? _passwordMismatchMessage
                              : null,
                          validator: _validatePasswordConfirmation,
                        ),
                        SizedBox(height: AppSpacing.xxxl),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AuthSizes.registerButtonHorizontalInset,
                          ),
                          child: AuthPrimaryButtonWidget(
                            label: 'Inscription',
                            isLoading: _isSubmitting,
                            onPressed: _canSubmit && !_isSubmitting
                                ? _submit
                                : null,
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
      ),
    );
  }
}

String? _validateRequired(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Ce champ est requis.';
  }
  return null;
}
