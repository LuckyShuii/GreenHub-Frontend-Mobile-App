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
    this.leading,
    this.backgroundColor = Colors.white,
    this.onTap,
    this.decoration,
    this.padding,
    this.titleStyle,
    this.descriptionStyle,
    this.textAlign = TextAlign.start,
    this.minHeight = 0,
    this.bottomAligned = false,
    this.descriptionSpacing,
  });

  final String title;
  final String description;
  final IconData? icon;
  final Widget? leading;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final BoxDecoration? decoration;
  final EdgeInsetsGeometry? padding;
  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;
  final TextAlign textAlign;
  final double minHeight;
  final bool bottomAligned;
  final double? descriptionSpacing;

  @override
  Widget build(BuildContext context) {
    final Widget? cardLeading =
        leading ??
        (icon == null ? null : Icon(icon, color: AppColors.v700, size: 28));
    final BoxDecoration cardDecoration =
        decoration ??
        BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          boxShadow: AppShadows.md,
        );

    return InkWell(
      onTap: onTap,
      borderRadius: cardDecoration.borderRadius?.resolve(
        Directionality.of(context),
      ),
      child: Container(
        constraints: BoxConstraints(minHeight: minHeight),
        decoration: cardDecoration,
        padding: padding ?? EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: bottomAligned ? MainAxisSize.min : MainAxisSize.max,
          mainAxisAlignment: bottomAligned
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (cardLeading != null)
              Padding(
                padding: EdgeInsets.only(
                  bottom: bottomAligned ? AppSpacing.md : AppSpacing.sm,
                ),
                child: cardLeading,
              ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: textAlign == TextAlign.start
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  title,
                  style: titleStyle ?? AppTextStyles.subtitle,
                  textAlign: textAlign,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: descriptionSpacing ?? AppSpacing.xs),
                Text(
                  description,
                  style: descriptionStyle ?? AppTextStyles.bodySmall,
                  textAlign: textAlign,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
