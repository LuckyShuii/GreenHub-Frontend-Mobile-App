import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../features/auth/data/auth_session.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_radii.dart';
import '../../../shared/theme/app_shadows.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/screens/page_under_construction_screen.dart';
import '../theme/settings_sizes.dart';
import '../theme/settings_text_styles.dart';
import '../widgets/settings_page_header_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({required this.authSession, super.key});

  final AuthSession authSession;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Set<int> _expandedSections = <int>{};

  static const List<_SettingsSection> _sections = <_SettingsSection>[
    _SettingsSection(
      title: 'Profil',
      iconAsset: 'settings_profile.svg',
      entries: <String>['Information personnelle', 'Supprimer mon compte'],
    ),
    _SettingsSection(
      title: 'Préférences',
      iconAsset: 'settings_notifications.svg',
      entries: <String>['Notification', 'Accessibilité'],
    ),
    _SettingsSection(
      title: 'Confidentialité',
      iconAsset: 'settings_privacy.svg',
      entries: <String>['Autorisations', 'Gestion des données'],
    ),
    _SettingsSection(
      title: 'Aide & Support',
      iconAsset: 'settings_support.svg',
      entries: <String>['FAQ', 'Signaler un bug', 'Nous contacter'],
    ),
    _SettingsSection(
      title: 'À propos',
      iconAsset: 'settings_about.svg',
      entries: <String>['Mention légale', 'Politique de confidentialité'],
    ),
  ];

  void _openConstruction() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PageUnderConstructionScreen(
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _openEntry(String entry) {
    switch (entry) {
      case 'Information personnelle':
        context.push<void>(AppRoutes.profile);
      case 'Supprimer mon compte':
        context.push<void>(AppRoutes.deleteAccount);
      default:
        _openConstruction();
    }
  }

  Future<void> _logout() async {
    await widget.authSession.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(
                SettingsSizes.pageInset,
                SettingsSizes.pageTopInset,
                SettingsSizes.pageInset,
                AppSpacing.lg,
              ),
              child: SettingsPageHeaderWidget(
                title: 'Paramètre',
                onBack: () => _goBack(context),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  SettingsSizes.pageInset,
                  0,
                  SettingsSizes.pageInset,
                  AppSpacing.md,
                ),
                children: <Widget>[
                  for (
                    int index = 0;
                    index < _sections.length;
                    index++
                  ) ...<Widget>[
                    _SettingsSectionCard(
                      section: _sections[index],
                      isExpanded: _expandedSections.contains(index),
                      onToggle: () => setState(() {
                        if (!_expandedSections.add(index)) {
                          _expandedSections.remove(index);
                        }
                      }),
                      onEntryTap: _openEntry,
                    ),
                    SizedBox(height: SettingsSizes.sectionGap),
                  ],
                  _SettingsActionCard(
                    label: 'Déconnexion',
                    iconAsset: 'settings_logout.svg',
                    onTap: _logout,
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _goBack(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(AppRoutes.home);
  }
}

class _SettingsSection {
  const _SettingsSection({
    required this.title,
    required this.iconAsset,
    required this.entries,
  });

  final String title;
  final String iconAsset;
  final List<String> entries;
}

class _SettingsSectionCard extends StatelessWidget {
  const _SettingsSectionCard({
    required this.section,
    required this.isExpanded,
    required this.onToggle,
    required this.onEntryTap,
  });

  final _SettingsSection section;
  final bool isExpanded;
  final VoidCallback onToggle;
  final ValueChanged<String> onEntryTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.o100),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: AppShadows.field,
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: SettingsSizes.sectionHeaderHeight,
            child: Semantics(
              button: true,
              expanded: isExpanded,
              label: section.title,
              child: InkWell(
                key: Key('settings-section-${section.title}'),
                borderRadius: BorderRadius.circular(AppRadii.lg),
                onTap: onToggle,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SettingsSizes.sectionHeaderInset,
                  ),
                  child: Row(
                    children: <Widget>[
                      Transform.flip(
                        key: Key('settings-icon-${section.iconAsset}'),
                        flipY: section.iconAsset == 'settings_profile.svg',
                        child: SvgPicture.asset(
                          'assets/icons/${section.iconAsset}',
                          width: SettingsSizes.sectionIconSize,
                          height: SettingsSizes.sectionIconSize,
                          excludeFromSemantics: true,
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          section.title,
                          style: SettingsTextStyles.sectionTitle,
                        ),
                      ),
                      RotatedBox(
                        quarterTurns: isExpanded ? 1 : 2,
                        child: SvgPicture.asset(
                          'assets/icons/settings_chevron.svg',
                          width: SettingsSizes.sectionChevronSize,
                          height: SettingsSizes.sectionChevronSize,
                          excludeFromSemantics: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: EdgeInsets.fromLTRB(
                SettingsSizes.sectionContentInset,
                AppSpacing.sm,
                SettingsSizes.sectionContentInset,
                SettingsSizes.sectionContentInset,
              ),
              child: Column(
                children: <Widget>[
                  for (
                    int index = 0;
                    index < section.entries.length;
                    index++
                  ) ...<Widget>[
                    _SettingsOption(
                      label: section.entries[index],
                      isDestructive:
                          section.entries[index] == 'Supprimer mon compte',
                      onTap: () => onEntryTap(section.entries[index]),
                    ),
                    if (index < section.entries.length - 1)
                      SizedBox(height: SettingsSizes.optionGap),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SettingsOption extends StatelessWidget {
  const _SettingsOption({
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final Color accent = isDestructive ? AppColors.erreur : AppColors.o100;
    return SizedBox(
      height: SettingsSizes.optionHeight,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.field),
        child: InkWell(
          key: Key('settings-entry-$label'),
          borderRadius: BorderRadius.circular(AppRadii.field),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: accent),
              borderRadius: BorderRadius.circular(AppRadii.field),
              boxShadow: isDestructive
                  ? AppShadows.errorField
                  : AppShadows.field,
            ),
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: SettingsTextStyles.optionTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsActionCard extends StatelessWidget {
  const _SettingsActionCard({
    required this.label,
    required this.iconAsset,
    required this.onTap,
    this.isDestructive = false,
  });

  final String label;
  final String iconAsset;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final Color accent = isDestructive ? AppColors.erreur : AppColors.o100;
    return SizedBox(
      height: SettingsSizes.sectionHeaderHeight,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: accent),
              borderRadius: BorderRadius.circular(AppRadii.lg),
              boxShadow: isDestructive
                  ? AppShadows.errorField
                  : AppShadows.field,
            ),
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: <Widget>[
                Transform.flip(
                  key: Key('settings-icon-$iconAsset'),
                  flipY: true,
                  child: SvgPicture.asset(
                    'assets/icons/$iconAsset',
                    width: SettingsSizes.sectionIconSize,
                    height: SettingsSizes.sectionIconSize,
                    excludeFromSemantics: true,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(label, style: SettingsTextStyles.sectionTitle),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
