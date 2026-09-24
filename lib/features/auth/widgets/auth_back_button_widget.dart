import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_radii.dart';
import '../../../shared/theme/app_shadows.dart';
import '../theme/auth_sizes.dart';

class AuthBackButtonWidget extends StatelessWidget {
  const AuthBackButtonWidget({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Retour',
      child: SizedBox(
        height: AuthSizes.backButtonSize,
        width: AuthSizes.backButtonSize,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.o40,
            border: Border.all(color: AppColors.o100),
            borderRadius: BorderRadius.circular(AppRadii.field),
            boxShadow: AppShadows.field,
          ),
          child: Material(
            color: AppColors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadii.field),
              onTap: onPressed,
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/back_chevron.svg',
                  height: AuthSizes.backIconSize,
                  width: AuthSizes.backIconSize,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
