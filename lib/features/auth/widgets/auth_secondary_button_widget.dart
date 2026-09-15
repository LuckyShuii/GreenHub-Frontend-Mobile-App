import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_radii.dart';
import '../theme/auth_sizes.dart';
import '../theme/auth_text_styles.dart';

class AuthSecondaryButtonWidget extends StatelessWidget {
  const AuthSecondaryButtonWidget({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: SizedBox(
        height: AuthSizes.actionHeight,
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.transparent,
            foregroundColor: AppColors.o40,
            side: const BorderSide(color: AppColors.o40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            textStyle: AuthTextStyles.action,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
