import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_radii.dart';
import '../../../shared/theme/app_shadows.dart';
import '../../../shared/theme/app_sizes.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../utils/password_policy.dart';

class PasswordCompositionWidget extends StatelessWidget {
  const PasswordCompositionWidget({
    required this.controller,
    required this.password,
    this.hasError = false,
    this.validator,
    super.key,
  });

  final TextEditingController controller;
  final String password;
  final bool hasError;
  final String? Function(String? value)? validator;

  @override
  Widget build(BuildContext context) {
    final PasswordPolicy policy = PasswordPolicy(password);
    final bool showRequirements = password.isNotEmpty;
    final OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.field),
      borderSide: BorderSide(
        color: hasError ? AppColors.erreur : AppColors.o100,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Text('Mot de passe', style: AppTextStyles.formLabel),
        ),
        SizedBox(height: AppSpacing.fieldLabelGap),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: hasError ? AppColors.erreur : AppColors.o100,
            ),
            borderRadius: BorderRadius.circular(AppRadii.field),
            boxShadow: hasError ? AppShadows.errorField : AppShadows.field,
          ),
          child: ConstrainedBox(
            key: const Key('password-composition-panel'),
            constraints: BoxConstraints(
              minHeight: showRequirements
                  ? toRem(10.625)
                  : AppSizes.inputFieldHeight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  height: AppSizes.inputFieldHeight,
                  child: TextFormField(
                    key: const Key('register-password-field'),
                    controller: controller,
                    obscureText: true,
                    validator: validator,
                    style: AppTextStyles.formInput,
                    cursorColor: AppColors.v700,
                    decoration: InputDecoration(
                      hintText: '•••••••',
                      hintStyle: AppTextStyles.formInput,
                      errorStyle: const TextStyle(fontSize: 0, height: 0),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.inputHorizontal,
                        vertical: AppSpacing.inputVertical,
                      ),
                      border: border,
                      enabledBorder: border,
                      focusedBorder: border.copyWith(
                        borderSide: BorderSide(
                          color: hasError ? AppColors.erreur : AppColors.v700,
                        ),
                      ),
                      errorBorder: border.copyWith(
                        borderSide: const BorderSide(color: AppColors.erreur),
                      ),
                      focusedErrorBorder: border.copyWith(
                        borderSide: const BorderSide(color: AppColors.erreur),
                      ),
                    ),
                  ),
                ),
                if (showRequirements)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      toRem(1.625),
                      toRem(0.625),
                      AppSpacing.xs,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _PasswordRequirement(
                          label: 'Min. 12 caractères',
                          isSatisfied: policy.hasMinimumLength,
                        ),
                        _PasswordRequirement(
                          label: 'Min. 1 majuscule',
                          isSatisfied: policy.hasUppercase,
                        ),
                        _PasswordRequirement(
                          label: 'Min. 1 minuscule',
                          isSatisfied: policy.hasLowercase,
                        ),
                        _PasswordRequirement(
                          label: 'Min. 1 chiffre',
                          isSatisfied: policy.hasDigit,
                        ),
                        _PasswordRequirement(
                          label: 'Min. 1 caractère spécial',
                          isSatisfied: policy.hasSpecialCharacter,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PasswordRequirement extends StatelessWidget {
  const _PasswordRequirement({required this.label, required this.isSatisfied});

  final String label;
  final bool isSatisfied;

  @override
  Widget build(BuildContext context) {
    final double fontSize = toRem(0.875);
    final double lineHeight =
        MediaQuery.textScalerOf(context).scale(fontSize) * (19 / 14);

    return SizedBox(
      height: lineHeight,
      child: Text(
        '• $label',
        key: Key('password-requirement-$label'),
        style: TextStyle(
          color: isSatisfied ? AppColors.v650 : AppColors.o300,
          fontFamily: AppTextStyles.bodyFontFamily,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          height: 19 / 14,
        ),
      ),
    );
  }
}
