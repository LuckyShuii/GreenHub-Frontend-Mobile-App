import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';

/// Bouton d'action flottant circulaire avec icône SVG
class FABSvgButtonWidget extends StatelessWidget {
  const FABSvgButtonWidget({
    super.key,
    required this.assetPath,
    required this.onPressed,
    this.backgroundColor = AppColors.v700,
    this.foregroundColor = Colors.white,
    this.size = 56,
    this.iconSize = 24,
  });

  final String assetPath;
  final VoidCallback onPressed;
  final Color backgroundColor;

  /// Couleur appliquée aux SVG monochromes.
  /// Mettre null pour conserver les couleurs originales du SVG.
  final Color? foregroundColor;

  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        boxShadow: AppShadows.lg,
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Center(
            child: SvgPicture.asset(
              assetPath,
              width: iconSize,
              height: iconSize,
              fit: BoxFit.contain,
              colorFilter: foregroundColor == null
                  ? null
                  : ColorFilter.mode(
                foregroundColor!,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
