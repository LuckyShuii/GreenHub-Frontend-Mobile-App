import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_radii.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/content_card_widget.dart';
import '../../auth/data/auth_session.dart';
import '../../auth/data/models/user_response.dart';
import '../theme/home_colors.dart';
import '../theme/home_shadows.dart';
import '../theme/home_sizes.dart';
import '../theme/home_text_styles.dart';
import '../widgets/eco_progress_card_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.authSession, super.key});

  final AuthSession authSession;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<UserResponse> _currentUser = widget.authSession
      .fetchCurrentUser();
  bool _isNavigating = false;

  Future<void> _open(String route) async {
    if (_isNavigating) {
      return;
    }
    _isNavigating = true;
    try {
      await context.push<void>(route);
    } finally {
      _isNavigating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: HomeSizes.contentMaxWidth,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        _header(),
                        SizedBox(height: HomeSizes.headerBottomGap),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: HomeSizes.horizontalPadding,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              const EcoProgressCardWidget(),
                              SizedBox(height: HomeSizes.separatorTopGap),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: HomeSizes.separatorInset,
                                ),
                                child: SvgPicture.asset(
                                  'assets/icons/home_separator.svg',
                                  height: HomeSizes.separatorHeight,
                                  fit: BoxFit.fill,
                                  excludeFromSemantics: true,
                                ),
                              ),
                              SizedBox(height: HomeSizes.cardGap),
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Expanded(
                                      child: _shortcutCard(
                                        title: 'Légumes de saison',
                                        description:
                                            'Avant de faire vos courses !',
                                        asset: 'assets/icons/home_carrot.svg',
                                        iconWidth: HomeSizes.carrotIcon,
                                        iconHeight: HomeSizes.carrotIcon,
                                        route: AppRoutes.seasonalVegetables,
                                      ),
                                    ),
                                    SizedBox(width: HomeSizes.cardRowGap),
                                    Expanded(
                                      child: _shortcutCard(
                                        title: 'Guide de tri',
                                        description: 'Pour bien trier !',
                                        asset: 'assets/icons/home_recycle.svg',
                                        iconWidth: HomeSizes.recycleIcon,
                                        iconHeight: HomeSizes.recycleIcon,
                                        route: AppRoutes.sortingGuide,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: HomeSizes.cardGap),
                              _shortcutCard(
                                title: 'Les posts de la communauté',
                                description: 'Vous inspirer des meilleures !',
                                asset: 'assets/icons/home_community.svg',
                                iconWidth: HomeSizes.communityIconWidth,
                                iconHeight: HomeSizes.communityIconHeight,
                                route: AppRoutes.community,
                                muted: true,
                              ),
                              SizedBox(height: HomeSizes.contentBottomGap),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height:
                      HomeSizes.navigationHeight +
                      HomeSizes.navigationBottomGap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        HomeSizes.headerPadding,
        HomeSizes.topPadding,
        HomeSizes.horizontalPadding,
        0,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: HomeSizes.settingsSize),
        child: Row(
          children: <Widget>[
            Expanded(
              child: FutureBuilder<UserResponse>(
                future: _currentUser,
                builder: (context, snapshot) {
                  final String firstName =
                      snapshot.data?.firstName.trim() ?? '';
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        firstName.isEmpty ? 'Accueil' : firstName,
                        style: HomeTextStyles.userName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (snapshot.hasError)
                        Text(
                          'Impossible de charger votre profil.',
                          style: AppTextStyles.formError,
                        ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Container(
              width: HomeSizes.settingsSize,
              height: HomeSizes.settingsSize,
              decoration: BoxDecoration(
                color: AppColors.o40,
                border: Border.all(color: AppColors.o100),
                borderRadius: BorderRadius.circular(AppRadii.field),
                boxShadow: HomeShadows.surface,
              ),
              child: IconButton(
                tooltip: 'Réglages',
                onPressed: () => _open(AppRoutes.settings),
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.field),
                  ),
                ),
                icon: SvgPicture.asset(
                  'assets/icons/home_settings.svg',
                  width: HomeSizes.settingsIconWidth,
                  height: HomeSizes.settingsIconHeight,
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shortcutCard({
    required String title,
    required String description,
    required String asset,
    required double iconWidth,
    required double iconHeight,
    required String route,
    bool muted = false,
  }) {
    return ContentCardWidget(
      title: title,
      description: description,
      minHeight: HomeSizes.cardHeight,
      bottomAligned: true,
      padding: EdgeInsets.fromLTRB(
        HomeSizes.horizontalPadding,
        HomeSizes.horizontalPadding,
        HomeSizes.horizontalPadding,
        HomeSizes.cardBottomPadding,
      ),
      textAlign: TextAlign.right,
      titleStyle: muted
          ? HomeTextStyles.communityTitle
          : HomeTextStyles.cardTitle,
      descriptionStyle: muted
          ? HomeTextStyles.communityDescription
          : HomeTextStyles.cardDescription,
      descriptionSpacing: AppSpacing.xxs,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.o100),
        borderRadius: BorderRadius.circular(AppRadii.md),
        boxShadow: HomeShadows.surface,
      ),
      leading: Opacity(
        opacity: muted ? HomeColors.communityOpacity : 1,
        child: Container(
          width: HomeSizes.cardIconBox,
          height: HomeSizes.cardIconBox,
          decoration: BoxDecoration(
            color: HomeColors.iconBackground,
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          child: Center(
            child: SvgPicture.asset(
              asset,
              width: iconWidth,
              height: iconHeight,
              excludeFromSemantics: true,
            ),
          ),
        ),
      ),
      onTap: () => _open(route),
    );
  }
}
