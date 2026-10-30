import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../features/auth/data/auth_session.dart';
import '../../../features/auth/data/models/user_response.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_radii.dart';
import '../../../shared/theme/app_shadows.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../features/auth/widgets/auth_primary_button_widget.dart';
import '../theme/settings_sizes.dart';
import '../widgets/settings_page_header_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({required this.authSession, super.key});

  final AuthSession authSession;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserResponse> _user;

  @override
  void initState() {
    super.initState();
    _user = widget.authSession.fetchCurrentUser();
  }

  Future<void> _editProfile(UserResponse user) async {
    final UserResponse? updated = await context.push<UserResponse>(
      AppRoutes.profileEdit,
      extra: user,
    );
    if (updated != null && mounted) {
      setState(() {
        _user = Future<UserResponse>.value(updated);
      });
    }
  }

  Future<void> _changePassword() async {
    await context.push<void>(AppRoutes.passwordEdit);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            SettingsSizes.pageInset,
            SettingsSizes.pageTopInset,
            SettingsSizes.pageInset,
            AppSpacing.md,
          ),
          child: Column(
            children: <Widget>[
              SettingsPageHeaderWidget(
                title: 'Profil',
                onBack: () => _goBack(context),
                trailing: FutureBuilder<UserResponse>(
                  future: _user,
                  builder: (context, snapshot) => _ProfileHeaderAction(
                    tooltip: 'Modifier le profil',
                    onPressed: snapshot.hasData
                        ? () => _editProfile(snapshot.data!)
                        : null,
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              Expanded(
                child: FutureBuilder<UserResponse>(
                  future: _user,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Impossible de charger votre profil.',
                          style: AppTextStyles.formError,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final UserResponse user = snapshot.data!;
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _ProfileValue(label: 'Prénom', value: user.firstName),
                          SizedBox(height: SettingsSizes.profileFieldGap),
                          _ProfileValue(label: 'Nom', value: user.lastName),
                          SizedBox(height: SettingsSizes.profileFieldGap),
                          _ProfileValue(
                            label: 'Pseudonyme',
                            value: user.username,
                          ),
                          SizedBox(height: SettingsSizes.profileFieldGap),
                          _ProfileValue(label: 'Email', value: user.email),
                          SizedBox(height: SettingsSizes.profileFieldGap),
                          _ProfileValue(
                            label: 'Code postal',
                            value: user.postalCode ?? '',
                          ),
                          SizedBox(height: SettingsSizes.profileFieldGap),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: SettingsSizes.labelInset,
                            ),
                            child: Text(
                              'Mot de passe',
                              style: AppTextStyles.formLabel,
                            ),
                          ),
                          SizedBox(height: AppSpacing.lg),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: SettingsSizes.destructiveButtonInset,
                            ),
                            child: AuthPrimaryButtonWidget(
                              label: 'Changer votre mot de passe',
                              onPressed: _changePassword,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _goBack(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(AppRoutes.settings);
  }
}

class _ProfileValue extends StatelessWidget {
  const _ProfileValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: SettingsSizes.labelInset),
          child: Text(label, style: AppTextStyles.formLabel),
        ),
        SizedBox(height: AppSpacing.fieldLabelGap),
        Container(
          constraints: BoxConstraints(
            minHeight: SettingsSizes.profileFieldHeight,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.o100),
            borderRadius: BorderRadius.circular(AppRadii.field),
            boxShadow: AppShadows.field,
          ),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            value.isEmpty ? 'Non renseignée' : value,
            style: AppTextStyles.formInput,
          ),
        ),
      ],
    );
  }
}

class _ProfileHeaderAction extends StatelessWidget {
  const _ProfileHeaderAction({required this.tooltip, required this.onPressed});

  final String tooltip;
  final VoidCallback? onPressed;

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
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Transform.flip(
          flipY: true,
          child: SvgPicture.asset(
            'assets/icons/profile_edit.svg',
            width: SettingsSizes.editActionIconWidth,
            height: SettingsSizes.editActionIconHeight,
            excludeFromSemantics: true,
          ),
        ),
      ),
    );
  }
}
