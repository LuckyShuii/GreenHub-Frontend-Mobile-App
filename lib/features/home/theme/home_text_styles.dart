import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import 'home_colors.dart';

class HomeTextStyles {
  static final TextStyle _base = AppTextStyles.body.copyWith(
    fontFamily: 'HomeNunito',
    fontVariations: const <FontVariation>[FontVariation('wght', 400)],
    letterSpacing: 0,
    height: 1.35,
  );
  static final TextStyle userName = _base.copyWith(
    fontSize: 40,
    fontWeight: FontWeight.w800,
    fontVariations: const <FontVariation>[FontVariation('wght', 800)],
  );
  static final TextStyle ecoTitle = _base.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    fontVariations: const <FontVariation>[FontVariation('wght', 600)],
    color: AppColors.o50,
  );
  static final TextStyle level = ecoTitle.copyWith(
    fontWeight: FontWeight.w800,
    fontVariations: const <FontVariation>[FontVariation('wght', 800)],
    color: AppColors.o100,
  );
  static final TextStyle progress = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    fontVariations: const <FontVariation>[FontVariation('wght', 500)],
    height: 1.25,
    color: AppColors.o50,
  );
  static final TextStyle cardTitle = _base.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    fontVariations: const <FontVariation>[FontVariation('wght', 700)],
    color: Colors.black,
  );
  static final TextStyle cardDescription = _base.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    fontVariations: const <FontVariation>[FontVariation('wght', 500)],
    color: AppColors.o500,
  );
  static final TextStyle communityTitle = cardTitle.copyWith(
    color: cardTitle.color!.withValues(alpha: HomeColors.communityOpacity),
  );
  static final TextStyle communityDescription = cardDescription.copyWith(
    color: cardDescription.color!.withValues(
      alpha: HomeColors.communityOpacity,
    ),
  );

  const HomeTextStyles._();
}
