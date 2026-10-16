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
    this.size = 60,
    this.iconSize = 32,
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
    const borderColor = Color(0xFFE2E4DF);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: borderColor,
            offset: Offset(2, 3),
            blurRadius: 0,
            spreadRadius: 0,
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
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
