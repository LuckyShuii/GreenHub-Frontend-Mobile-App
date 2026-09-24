import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../shared/services/app_notification_service.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/theme/app_sizes.dart';
import '../../../shared/widgets/app_notification_host_widget.dart';
import '../../../shared/widgets/auth_text_field_widget.dart';
import '../data/auth_api_service.dart';
import '../data/models/register_request.dart';
import '../theme/auth_sizes.dart';
import '../utils/password_policy.dart';
import '../widgets/auth_form_layout_widget.dart';
import '../widgets/auth_primary_button_widget.dart';
import '../widgets/password_composition_widget.dart';
import '../utils/auth_validators.dart';

enum _RegisterApiErrorField { email, username }

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
  final ScrollController _scrollController = ScrollController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _usernameFocusNode = FocusNode();
  final GlobalKey _emailFieldKey = GlobalKey();
  final GlobalKey _usernameFieldKey = GlobalKey();
  late final AuthApiService _authApiService;
  bool _hasPasswordMismatch = false;
  bool _isSubmitting = false;
  bool _hasEmailApiError = false;
  bool _hasUsernameApiError = false;

  @override
  void initState() {
    super.initState();
    _authApiService = widget.authApiService ?? AuthApiService();
    _passwordController.addListener(_updatePasswordState);
    _passwordConfirmationController.addListener(_updatePasswordState);
    _emailController.addListener(_clearEmailApiError);
    _usernameController.addListener(_clearUsernameApiError);
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
    _emailController.removeListener(_clearEmailApiError);
    _usernameController.removeListener(_clearUsernameApiError);
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    _scrollController.dispose();
    _emailFocusNode.dispose();
    _usernameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _hasEmailApiError = false;
      _hasUsernameApiError = false;
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
      AppNotificationHost.of(context).showSuccess(
        'Votre compte a été créé. Vous pouvez maintenant vous connecter.',
      );
      context.go(AppRoutes.login);
    } on AuthApiException catch (error) {
      if (mounted) {
        AppNotificationHost.of(context).showError(error.message);
        _applyApiError(error.message);
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

  void _clearEmailApiError() {
    if (_hasEmailApiError && mounted) {
      setState(() {
        _hasEmailApiError = false;
      });
    }
  }

  void _clearUsernameApiError() {
    if (_hasUsernameApiError && mounted) {
      setState(() {
        _hasUsernameApiError = false;
      });
    }
  }

  void _applyApiError(String message) {
    final String normalizedMessage = message.toLowerCase();
    final _RegisterApiErrorField? field =
        normalizedMessage.contains('e-mail') ||
            normalizedMessage.contains('email')
        ? _RegisterApiErrorField.email
        : normalizedMessage.contains('pseudonyme')
        ? _RegisterApiErrorField.username
        : null;

    if (field == null) {
      return;
    }

    setState(() {
      _hasEmailApiError = field == _RegisterApiErrorField.email;
      _hasUsernameApiError = field == _RegisterApiErrorField.username;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusAndScrollToApiError(field);
      }
    });
  }

  Future<void> _focusAndScrollToApiError(_RegisterApiErrorField field) async {
    final FocusNode focusNode = field == _RegisterApiErrorField.email
        ? _emailFocusNode
        : _usernameFocusNode;
    final GlobalKey fieldKey = field == _RegisterApiErrorField.email
        ? _emailFieldKey
        : _usernameFieldKey;
    final BuildContext? fieldContext = fieldKey.currentContext;

    if (fieldContext == null || !_scrollController.hasClients) {
      return;
    }

    final RenderObject? renderObject = fieldContext.findRenderObject();
    if (renderObject is! RenderBox) {
      return;
    }

    final AppNotificationService notificationService = AppNotificationHost.of(
      context,
    );
    final int visibleCount = notificationService.visibleNotifications.length;
    final double notificationHeight = toRem(3.75);
    final double notificationGap = AppSpacing.xs;
    final double notificationStackHeight = visibleCount == 0
        ? 0
        : visibleCount * notificationHeight +
              (visibleCount - 1) * notificationGap;
    final double notificationBottom =
        MediaQuery.paddingOf(context).top +
        AppSpacing.sm +
        notificationStackHeight +
        AppSpacing.sm;
    final double desiredFieldTop = notificationBottom + AppSpacing.sm;
    final double fieldTop = renderObject.localToGlobal(Offset.zero).dy;
    final double targetOffset =
        (_scrollController.offset + fieldTop - desiredFieldTop).clamp(
          _scrollController.position.minScrollExtent,
          _scrollController.position.maxScrollExtent,
        );

    await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
    if (!mounted) {
      return;
    }
    focusNode.requestFocus();
    if ((targetOffset - _scrollController.offset).abs() > 0.5) {
      await _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    if (!mounted) {
      return;
    }
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
    return AuthFormLayoutWidget(
      title: 'Création de votre\ncompte Green’Hub',
      subtitle: 'Bienvenu dans l’écosystème !',
      formKey: _formKey,
      onBack: _goBack,
      scrollController: _scrollController,
      children: <Widget>[
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
        Container(
          key: _emailFieldKey,
          child: AuthTextFieldWidget(
            key: const Key('register-email-field'),
            label: 'Email',
            hint: 'Email*',
            controller: _emailController,
            focusNode: _emailFocusNode,
            hasError: _hasEmailApiError,
            keyboardType: TextInputType.emailAddress,
            validator: validateEmail,
          ),
        ),
        SizedBox(height: AppSpacing.fieldGap),
        Container(
          key: _usernameFieldKey,
          child: AuthTextFieldWidget(
            key: const Key('register-username-field'),
            label: 'Pseudonyme',
            hint: 'Pseudonyme*',
            controller: _usernameController,
            focusNode: _usernameFocusNode,
            hasError: _hasUsernameApiError,
            validator: _validateRequired,
          ),
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
          errorText: _hasPasswordMismatch ? _passwordMismatchMessage : null,
          validator: _validatePasswordConfirmation,
        ),
        SizedBox(height: AppSpacing.xxxl),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AuthSizes.formButtonHorizontalInset,
          ),
          child: AuthPrimaryButtonWidget(
            label: 'Inscription',
            isLoading: _isSubmitting,
            onPressed: _canSubmit && !_isSubmitting ? _submit : null,
          ),
        ),
      ],
    );
  }
}

String? _validateRequired(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Ce champ est requis.';
  }
  return null;
}
