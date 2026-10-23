import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../features/auth/data/auth_api_service.dart';
import '../../../features/auth/data/auth_session.dart';
import '../../../features/auth/data/models/user_response.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_radii.dart';
import '../../../shared/theme/app_shadows.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/app_notification_host_widget.dart';
import '../theme/settings_sizes.dart';
import '../theme/settings_text_styles.dart';
import '../widgets/settings_page_header_widget.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({required this.authSession, super.key});

  final AuthSession authSession;

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  late final Future<UserResponse> _user = widget.authSession.fetchCurrentUser();
  bool _isDeleting = false;

  Future<void> _confirmDeletion(String email) async {
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) => AlertDialog(
            title: const Text('Supprimer votre compte ?'),
            content: Text(
              'Le compte $email et toutes les données associées seront supprimés définitivement.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Annuler'),
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.erreur,
                  side: const BorderSide(color: AppColors.erreur),
                ),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Supprimer définitivement'),
              ),
            ],
          ),
        ) ??
        false;
    if (confirmed) {
      await _deleteAccount();
    }
  }

  Future<void> _deleteAccount() async {
    setState(() => _isDeleting = true);
    try {
      await widget.authSession.deleteCurrentUser();
    } on AuthApiException catch (error) {
      if (mounted) {
        AppNotificationHost.of(context).showError(error.message);
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
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
              ),
              SizedBox(height: SettingsSizes.confirmationTopGap),
              Text(
                'Suppression du compte',
                style: SettingsTextStyles.pageTitle,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: SettingsSizes.confirmationTextGap),
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
                    return Column(
                      children: <Widget>[
                        Text(
                          'Êtes-vous certain de vouloir supprimer le compte associé à l’adresse mail ${snapshot.data!.email} ?',
                          textAlign: TextAlign.center,
                          style: SettingsTextStyles.confirmationBody,
                        ),
                        SizedBox(height: SettingsSizes.confirmationTextGap),
                        Text.rich(
                          TextSpan(
                            style: SettingsTextStyles.warningBody,
                            children: const <InlineSpan>[
                              TextSpan(
                                text:
                                    'La suppression de votre compte est instantanée, entraînant l’effacement définitif de toutes vos données. ',
                              ),
                              TextSpan(
                                text: 'Cette opération ne peut être annulée.',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Spacer(),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: SettingsSizes.destructiveButtonInset,
                          ),
                          child: _DeleteButton(
                            isDeleting: _isDeleting,
                            onPressed: _isDeleting
                                ? null
                                : () => _confirmDeletion(snapshot.data!.email),
                          ),
                        ),
                        SizedBox(height: AppSpacing.xxl),
                      ],
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

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.isDeleting, required this.onPressed});

  final bool isDeleting;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SettingsSizes.destructiveButtonHeight,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.md),
          boxShadow: AppShadows.primaryButton,
        ),
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.white,
            disabledBackgroundColor: AppColors.white,
            foregroundColor: AppColors.erreur,
            disabledForegroundColor: AppColors.erreur,
            side: const BorderSide(color: AppColors.erreur),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            textStyle: AppTextStyles.formLink,
          ),
          child: isDeleting
              ? const CircularProgressIndicator(color: AppColors.erreur)
              : const Text('Supprimer mon compte'),
        ),
      ),
    );
  }
}
