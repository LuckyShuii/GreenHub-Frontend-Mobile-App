import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_radii.dart';
import '../../../shared/theme/app_spacing.dart';
import '../theme/home_colors.dart';
import '../theme/home_shadows.dart';
import '../theme/home_sizes.dart';
import '../theme/home_text_styles.dart';

class EcoProgressCardWidget extends StatelessWidget {
  const EcoProgressCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: HomeSizes.ecoHeight),
      decoration: BoxDecoration(
        color: HomeColors.ecoCard,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: HomeShadows.eco,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              right: 0,
              child: SvgPicture.asset(
                'assets/icons/home_eco_decoration.svg',
                width: HomeSizes.ecoDecorationWidth,
                height: HomeSizes.ecoDecorationHeight,
                excludeFromSemantics: true,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                HomeSizes.ecoSidePadding,
                HomeSizes.ecoTopPadding,
                HomeSizes.ecoSidePadding,
                HomeSizes.ecoBottomPadding,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: HomeSizes.badgeWidth,
                        height: HomeSizes.badgeHeight,
                        child: Stack(
                          children: <Widget>[
                            Positioned(
                              top: 0,
                              left: 0,
                              width: HomeSizes.badgeFace,
                              height: HomeSizes.badgeFace,
                              child: const DecoratedBox(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: HomeShadows.progress,
                                ),
                              ),
                            ),
                            SvgPicture.asset(
                              'assets/icons/home_level_badge.svg',
                              width: HomeSizes.badgeWidth,
                              height: HomeSizes.badgeHeight,
                              excludeFromSemantics: true,
                            ),
                            Positioned.fill(
                              right: HomeSizes.badgeTextInsetRight,
                              bottom: HomeSizes.badgeTextInsetBottom,
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text('3', style: HomeTextStyles.level),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: HomeSizes.badgeTitleGap),
                      Expanded(
                        child: Text(
                          'Eco-baroudeur',
                          style: HomeTextStyles.ecoTitle,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: HomeSizes.progressTopGap),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: HomeSizes.progressSideInset,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Semantics(
                          label: 'Progression',
                          value: '190 sur 500',
                          child: Container(
                            key: const Key('home-eco-progress'),
                            width: double.infinity,
                            height: HomeSizes.progressHeight,
                            decoration: BoxDecoration(
                              color: HomeColors.iconBackground,
                              border: Border.all(
                                color: HomeColors.progressBorder,
                              ),
                              borderRadius: BorderRadius.circular(
                                HomeSizes.progressRadius,
                              ),
                              boxShadow: HomeShadows.progress,
                            ),
                            child: FractionallySizedBox(
                              widthFactor: HomeSizes.progressFraction,
                              heightFactor: 1,
                              alignment: Alignment.centerLeft,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: AppColors.v650,
                                  borderRadius: BorderRadius.circular(
                                    HomeSizes.progressRadius,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: AppSpacing.xxs),
                        Text('190 / 500', style: HomeTextStyles.progress),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Row(
                    children: <Widget>[
                      Expanded(child: _emptyTile()),
                      SizedBox(width: HomeSizes.ecoTileGap),
                      Expanded(child: _emptyTile()),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyTile() {
    return Container(
      height: HomeSizes.ecoTileHeight,
      decoration: BoxDecoration(
        color: AppColors.o40,
        border: Border.all(color: AppColors.o100),
        borderRadius: BorderRadius.circular(AppRadii.md),
        boxShadow: HomeShadows.surface,
      ),
    );
  }
}
