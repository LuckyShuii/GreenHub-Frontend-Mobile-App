import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../theme/auth_sizes.dart';

class AuthSeparatorWidget extends StatelessWidget {
  const AuthSeparatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: AuthSizes.loginSeparatorLineWidth,
          child: Divider(color: AppColors.o300, thickness: AppSpacing.xxs / 4),
        ),
        SizedBox(
          width: AuthSizes.loginSeparatorTextWidth,
          child: Text(
            'ou',
            textAlign: TextAlign.center,
            style: AppTextStyles.formSeparator,
          ),
        ),
        SizedBox(
          width: AuthSizes.loginSeparatorLineWidth,
          child: Divider(color: AppColors.o300, thickness: AppSpacing.xxs / 4),
        ),
      ],
    );
  }
}
