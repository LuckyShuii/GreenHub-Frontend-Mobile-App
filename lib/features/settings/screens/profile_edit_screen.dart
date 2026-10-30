import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../features/auth/data/auth_session.dart';
import '../../../features/auth/data/auth_api_service.dart';
import '../../../features/auth/data/models/profile_update_request.dart';
import '../../../features/auth/data/models/user_response.dart';
import '../../../features/auth/utils/auth_validators.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_radii.dart';
import '../../../shared/theme/app_shadows.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/widgets/app_notification_host_widget.dart';
import '../../../shared/widgets/auth_text_field_widget.dart';
import '../theme/settings_sizes.dart';
import '../widgets/settings_page_header_widget.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({
    required this.authSession,
    required this.user,
    super.key,
  });

  final AuthSession authSession;
  final UserResponse user;

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _postalCodeController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _usernameController = TextEditingController(text: widget.user.username);
    _emailController = TextEditingController(text: widget.user.email);
    _postalCodeController = TextEditingController(
      text: widget.user.postalCode ?? '',
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final UserResponse updated = await widget.authSession.updateCurrentUser(
        ProfileUpdateRequest(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          username: _usernameController.text,
          email: _emailController.text,
          postalCode: _postalCodeController.text,
        ),
      );
      if (!mounted) {
        return;
      }
      AppNotificationHost.of(context).showSuccess('Profil mis à jour.');
      context.pop<UserResponse>(updated);
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
                  onBack: () => context.pop(),
                  leading: _CancelButton(onPressed: () => context.pop()),
                  trailing: _HeaderSaveButton(
                    onPressed: _isSubmitting ? null : _save,
                    isSaving: _isSubmitting,
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        AuthTextFieldWidget(
                          label: 'Prénom',
                          hint: 'Prénom',
                          controller: _firstNameController,
                          validator: _validateRequired,
                        ),
                        SizedBox(height: SettingsSizes.profileFieldGap),
                        AuthTextFieldWidget(
                          label: 'Nom',
                          hint: 'Nom',
                          controller: _lastNameController,
                          validator: _validateRequired,
                        ),
                        SizedBox(height: SettingsSizes.profileFieldGap),
                        AuthTextFieldWidget(
                          key: const Key('profile-username-field'),
                          label: 'Pseudonyme',
                          hint: 'Pseudonyme',
                          controller: _usernameController,
                          validator: validateUsername,
                        ),
                        SizedBox(height: SettingsSizes.profileFieldGap),
                        AuthTextFieldWidget(
                          label: 'Email',
                          hint: 'Email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: validateEmail,
                        ),
                        SizedBox(height: SettingsSizes.profileFieldGap),
                        AuthTextFieldWidget(
                          label: 'Code postal',
                          hint: 'Code postal',
                          controller: _postalCodeController,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(5),
                          ],
                          validator: validatePostalCode,
                        ),
                      ],
                    ),
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

String? _validateRequired(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Ce champ est requis.';
  }
  return null;
}

class _HeaderSaveButton extends StatelessWidget {
  const _HeaderSaveButton({required this.onPressed, required this.isSaving});

  final VoidCallback? onPressed;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SettingsSizes.headerSize,
      height: SettingsSizes.headerSize,
      decoration: BoxDecoration(
        color: AppColors.o40,
        border: Border.all(
          color: onPressed == null ? AppColors.o100 : AppColors.v650,
        ),
        borderRadius: BorderRadius.circular(AppRadii.field),
      ),
      child: IconButton(
        tooltip: 'Enregistrer',
        onPressed: onPressed,
        icon: isSaving
            ? const CircularProgressIndicator(strokeWidth: 2)
            : SvgPicture.asset(
                'assets/icons/profile_check.svg',
                width: SettingsSizes.confirmActionIconSize,
                height: SettingsSizes.confirmActionIconSize,
                excludeFromSemantics: true,
              ),
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SettingsSizes.headerSize,
      height: SettingsSizes.headerSize,
      decoration: BoxDecoration(
        color: AppColors.o40,
        border: Border.all(color: AppColors.erreur),
        borderRadius: BorderRadius.circular(AppRadii.field),
        boxShadow: AppShadows.errorField,
      ),
      child: IconButton(
        tooltip: 'Annuler',
        onPressed: onPressed,
        icon: SvgPicture.asset(
          'assets/icons/profile_cancel.svg',
          width: SettingsSizes.confirmActionIconSize,
          height: SettingsSizes.confirmActionIconSize,
          excludeFromSemantics: true,
        ),
      ),
    );
  }
}
