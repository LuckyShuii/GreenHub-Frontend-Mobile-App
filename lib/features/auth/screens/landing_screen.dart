import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../shared/theme/app_colors.dart';
import '../theme/auth_colors.dart';
import '../theme/auth_sizes.dart';
import '../theme/auth_text_styles.dart';
import '../widgets/auth_primary_button_widget.dart';
import '../widgets/auth_secondary_button_widget.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.v900,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool isTablet =
              constraints.maxWidth >= AuthSizes.tabletBreakpoint;
          final double horizontalPadding = isTablet
              ? AuthSizes.landingHorizontalPaddingTablet
              : AuthSizes.landingHorizontalPadding;
          final double maxContentWidth = isTablet
              ? AuthSizes.contentMaxWidthTablet
              : AuthSizes.contentMaxWidthMobile;

          return Stack(
            children: <Widget>[
              const _LandingDecorations(),
              SafeArea(
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      top: AuthSizes.landingHeaderTop,
                      right: AuthSizes.landingHeaderRight,
                      bottom: AuthSizes.landingHeaderBottom,
                      left: AuthSizes.landingHeaderLeft,
                      child: const _LandingHeader(),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxContentWidth),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          child: const _LandingActions(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LandingHeader extends StatelessWidget {
  const _LandingHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text('Green\'Hub', style: AuthTextStyles.landingHero),
        SizedBox(height: AuthSizes.landingSubtitleTopSpacing),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: AuthSizes.landingSubtitleMaxWidth,
          ),
          child: Text(
            'La transition écologique un geste à la fois',
            style: AuthTextStyles.landingSubtitle,
          ),
        ),
      ],
    );
  }
}

class _LandingActions extends StatelessWidget {
  const _LandingActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AuthPrimaryButtonWidget(
          label: 'Connexion',
          onPressed: () => context.push(AppRoutes.login),
          isInverted: true,
        ),
        SizedBox(height: AuthSizes.landingButtonsGap),
        AuthSecondaryButtonWidget(
          label: 'Inscription',
          onPressed: () => context.push(AppRoutes.register),
        ),
        SizedBox(height: AuthSizes.landingLegalTopSpacing),
        Text(
          'En continuant, vous acceptez nos conditions',
          style: AuthTextStyles.landingLegal,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _LandingDecorations extends StatelessWidget {
  const _LandingDecorations();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: <Widget>[
          Positioned(
            top: AuthSizes.landingCircleOneTop,
            left: AuthSizes.landingCircleOneLeft,
            right: AuthSizes.landingCircleOneRight,
            bottom: AuthSizes.landingCircleOneBottom,
            child: _DecorationCircle(
              color: AuthColors.landingCircleOne,
              size: AuthSizes.landingCircleLarge,
            ),
          ),
          Positioned(
            top: AuthSizes.landingCircleTwoTop,
            bottom: AuthSizes.landingCircleTwoBottom,
            left: AuthSizes.landingCircleTwoLeft,
            right: AuthSizes.landingCircleTwoRight,
            child: _DecorationCircle(
              color: AuthColors.landingCircleTwo,
              size: AuthSizes.landingCircleMedium,
            ),
          ),
          Positioned(
            top: AuthSizes.landingCircleThreeTop,
            bottom: AuthSizes.landingCircleThreeBottom,
            left: AuthSizes.landingCircleThreeLeft,
            right: AuthSizes.landingCircleThreeRight,
            child: _DecorationCircle(
              color: AuthColors.landingCircleThree,
              size: AuthSizes.landingCircleMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorationCircle extends StatelessWidget {
  const _DecorationCircle({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: DecoratedBox(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
