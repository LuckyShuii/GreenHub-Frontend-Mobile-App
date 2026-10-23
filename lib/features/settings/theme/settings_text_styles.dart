import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_sizes.dart';
import '../../../shared/theme/app_text_styles.dart';

class SettingsTextStyles {
  static final TextStyle pageTitle = TextStyle(
    color: AppColors.o900,
    fontFamily: AppTextStyles.titleFontFamily,
    fontSize: toRem(2.5),
    fontWeight: FontWeight.w800,
    height: 1.1,
  );

  static final TextStyle sectionTitle = TextStyle(
    color: AppColors.o900,
    fontFamily: AppTextStyles.titleFontFamily,
    fontSize: toRem(1.75),
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static final TextStyle optionTitle = TextStyle(
    color: AppColors.o900,
    fontFamily: AppTextStyles.bodyFontFamily,
    fontSize: toRem(1.25),
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static final TextStyle confirmationBody = TextStyle(
    color: Colors.black,
    fontFamily: AppTextStyles.bodyFontFamily,
    fontSize: toRem(1.25),
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  static final TextStyle warningBody = confirmationBody.copyWith(
    fontWeight: FontWeight.w500,
  );

  static final TextStyle error = AppTextStyles.formError;

  const SettingsTextStyles._();
}
