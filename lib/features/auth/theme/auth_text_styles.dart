import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_sizes.dart';
import '../../../shared/theme/app_text_styles.dart';

class AuthTextStyles {
  static final TextStyle landingHero = TextStyle(
    fontSize: toRem(4),
    height: 1,
    fontWeight: FontWeight.w700,
    fontFamily: AppTextStyles.titleFontFamily,
    color: AppColors.o40,
  );

  static final TextStyle landingSubtitle = TextStyle(
    fontSize: toRem(1.5),
    height: 1.3,
    fontWeight: FontWeight.w700,
    fontFamily: AppTextStyles.titleFontFamily,
    color: AppColors.o300,
  );

  static final TextStyle action = TextStyle(
    fontSize: toRem(1.5),
    height: 1,
    fontWeight: FontWeight.w800,
    fontFamily: AppTextStyles.bodyFontFamily,
  );

  static final TextStyle landingLegal = TextStyle(
    fontSize: toRem(1),
    height: 1,
    fontWeight: FontWeight.w700,
    fontFamily: AppTextStyles.bodyFontFamily,
    color: AppColors.o300,
  );

  const AuthTextStyles._();
}
