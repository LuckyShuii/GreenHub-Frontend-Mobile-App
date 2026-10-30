import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_radii.dart';
import '../../../shared/theme/app_shadows.dart';
import '../theme/settings_sizes.dart';
import '../theme/settings_text_styles.dart';

class SettingsPageHeaderWidget extends StatelessWidget {
  const SettingsPageHeaderWidget({
    required this.title,
    required this.onBack,
    this.leading,
    this.trailing,
    super.key,
  });

  final String title;
  final VoidCallback onBack;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SettingsSizes.headerSize,
      child: Row(
        children: <Widget>[
          leading ??
              _HeaderButton(
                tooltip: 'Retour',
                onPressed: onBack,
                child: SvgPicture.asset(
                  'assets/icons/back_chevron.svg',
                  width: SettingsSizes.headerIconSize,
                  height: SettingsSizes.headerIconSize,
                  excludeFromSemantics: true,
                ),
              ),
          SizedBox(width: SettingsSizes.headerTitleGap),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: SettingsTextStyles.pageTitle,
            ),
          ),
          SizedBox(width: SettingsSizes.headerTitleGap),
          trailing ?? SizedBox(width: SettingsSizes.headerSize),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.tooltip,
    required this.onPressed,
    required this.child,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SettingsSizes.headerSize,
      height: SettingsSizes.headerSize,
      decoration: BoxDecoration(
        color: AppColors.o40,
        border: Border.all(color: AppColors.o100),
        borderRadius: BorderRadius.circular(AppRadii.field),
        boxShadow: AppShadows.field,
      ),
      child: IconButton(tooltip: tooltip, onPressed: onPressed, icon: child),
    );
  }
}
