import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_sizes.dart';

class AppTextStyles {
  static const String titleFontFamily = 'Bricolage Grotesque';
  static const String bodyFontFamily = 'Nunito';

  // Display 36/900
  static final TextStyle display = TextStyle(
    fontSize: toRem(2.25),
    fontWeight: FontWeight.w900,
    height: 1.1,
    letterSpacing: -0.5,
    fontFamily: titleFontFamily,
    color: AppColors.o900,
  );

  // Titre 26/800
  static final TextStyle title = TextStyle(
    fontSize: toRem(1.625),
    fontWeight: FontWeight.w800,
    height: 1.2,
    fontFamily: titleFontFamily,
    color: AppColors.o900,
  );

  // Sous-titre 20/700
  static final TextStyle subtitle = TextStyle(
    fontSize: toRem(1.25),
    fontWeight: FontWeight.w700,
    height: 1.3,
    fontFamily: titleFontFamily,
    color: AppColors.o900,
  );

  // Corps 16/400 - Numéro Sans
  static final TextStyle body = TextStyle(
    fontSize: toRem(1),
    fontWeight: FontWeight.w400,
    height: 1.45,
    fontFamily: bodyFontFamily,
    color: AppColors.o900,
  );

  // Label 12/700 CAPS
  static final TextStyle label = TextStyle(
    fontSize: toRem(0.75),
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: 0.5,
    fontFamily: bodyFontFamily,
    color: AppColors.o700,
  );

  // Variante pour le corps plus petit
  static final TextStyle bodySmall = TextStyle(
    fontSize: toRem(0.875),
    fontWeight: FontWeight.w400,
    height: 1.4,
    fontFamily: bodyFontFamily,
    color: AppColors.o700,
  );

  static final TextStyle formTitle = TextStyle(
    fontSize: toRem(2.375),
    fontWeight: FontWeight.w700,
    height: 1.1,
    fontFamily: titleFontFamily,
    color: AppColors.o900,
  );

  static final TextStyle formSubtitle = TextStyle(
    fontSize: toRem(1.5),
    fontWeight: FontWeight.w700,
    height: 1.2,
    fontFamily: titleFontFamily,
    color: AppColors.o300,
  );

  static final TextStyle formLabel = TextStyle(
    fontSize: toRem(1.5),
    fontWeight: FontWeight.w700,
    height: 1.2,
    fontFamily: bodyFontFamily,
    color: AppColors.o900,
  );

  static final TextStyle formInput = TextStyle(
    fontSize: toRem(1),
    fontWeight: FontWeight.w700,
    height: 1.375,
    fontFamily: bodyFontFamily,
    color: AppColors.o500,
  );

  static final TextStyle formError = TextStyle(
    fontSize: toRem(0.8125),
    fontWeight: FontWeight.w700,
    height: 1.2,
    fontFamily: bodyFontFamily,
    color: AppColors.erreur,
  );
}
