import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class ContentCardWidget extends StatelessWidget {
  const ContentCardWidget({
    super.key,
    required this.title,
    required this.description,
    this.icon,
    this.backgroundColor = Colors.white,
    this.onTap,
  });

  final String title;
  final String description;
  final IconData? icon;
  final Color backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          boxShadow: AppShadows.md,
        ),
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (icon != null)
              Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: Icon(
                  icon,
                  color: AppColors.v700,
                  size: 28,
                ),
              ),
            Text(
              title,
              style: AppTextStyles.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              description,
              style: AppTextStyles.bodySmall,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
