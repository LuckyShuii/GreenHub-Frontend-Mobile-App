import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  // Display 36/900
  static const TextStyle display = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w900,
    height: 1.1,
    letterSpacing: -0.5,
    color: AppColors.o900,
  );

  // Titre 26/800
  static const TextStyle title = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    height: 1.2,
    color: AppColors.o900,
  );

  // Sous-titre 20/700
  static const TextStyle subtitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: AppColors.o900,
  );

  // Corps 16/400 - Numéro Sans
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: AppColors.o900,
  );

  // Label 12/700 CAPS
  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: 0.5,
    color: AppColors.o700,
  );

  // Variante pour le corps plus petit
  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.o700,
  );
}

