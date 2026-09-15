import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_shadows.dart';
import '../theme/app_sizes.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class AuthTextFieldWidget extends StatelessWidget {
  const AuthTextFieldWidget({
    required this.label,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.hasError = false,
    this.errorText,
    this.autovalidate = true,
    this.keyboardType,
    this.validator,
    super.key,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final bool hasError;
  final String? errorText;
  final bool autovalidate;
  final TextInputType? keyboardType;
  final String? Function(String? value)? validator;

  @override
  Widget build(BuildContext context) {
    final bool showError = hasError || errorText != null;
    final OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.field),
      borderSide: BorderSide(
        color: showError ? AppColors.erreur : AppColors.o100,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Text(label, style: AppTextStyles.formLabel),
        ),
        SizedBox(height: AppSpacing.fieldLabelGap),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.field),
            boxShadow: showError ? AppShadows.errorField : AppShadows.field,
          ),
          child: TextFormField(
            autovalidateMode: autovalidate
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            validator: validator,
            style: AppTextStyles.formInput,
            cursorColor: AppColors.v700,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.formInput,
              errorStyle: AppTextStyles.formError,
              errorMaxLines: 2,
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.inputHorizontal,
                vertical: AppSpacing.inputVertical,
              ),
              constraints: BoxConstraints(
                minHeight: AppSizes.inputFieldHeight,
              ),
              border: border,
              enabledBorder: border,
              focusedBorder: border.copyWith(
                borderSide: BorderSide(
                  color: showError ? AppColors.erreur : AppColors.v700,
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
        if (errorText != null) ...<Widget>[
          SizedBox(height: AppSpacing.fieldLabelGap),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Text(errorText!, style: AppTextStyles.formError),
          ),
        ],
      ],
    );
  }
}