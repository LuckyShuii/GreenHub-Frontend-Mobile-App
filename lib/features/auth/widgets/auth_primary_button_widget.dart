import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_radii.dart';
import '../../../shared/theme/app_shadows.dart';
import '../../../shared/theme/app_sizes.dart';
import '../theme/auth_sizes.dart';
import '../theme/auth_text_styles.dart';

class AuthPrimaryButtonWidget extends StatelessWidget {
  const AuthPrimaryButtonWidget({
    required this.label,
    required this.onPressed,
    this.isInverted = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isInverted;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null;
    final Color backgroundColor = isDisabled
      ? AppColors.o300
      : isInverted
      ? AppColors.v50
      : AppColors.v650;
    final Color foregroundColor = isDisabled
      ? AppColors.o500
      : isInverted
      ? AppColors.v650
      : AppColors.o40;
    final BorderSide borderSide = isDisabled
      ? BorderSide(
        color: AppColors.o500,
        width: AppSizes.disabledButtonBorderWidth,
        )
      : BorderSide.none;

    return Semantics(
      button: true,
      enabled: !isDisabled,
      label: label,
      child: SizedBox(
        height: AuthSizes.actionHeight,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: isDisabled ? null : AppShadows.primaryButton,
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              textStyle: AuthTextStyles.action,
            ).copyWith(
              side: WidgetStatePropertyAll<BorderSide?>(
                borderSide,
              ),
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}
