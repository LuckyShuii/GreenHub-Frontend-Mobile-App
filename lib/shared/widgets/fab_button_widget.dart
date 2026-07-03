import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';

/// Bouton d'action flottant (FAB) circulaire avec icône
class FABButtonWidget extends StatelessWidget {
  const FABButtonWidget({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor = AppColors.v700,
    this.foregroundColor = Colors.white,
    this.size = 56,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final double size;

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
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(size / 2),
          child: Center(
            child: Icon(
              icon,
              color: foregroundColor,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
