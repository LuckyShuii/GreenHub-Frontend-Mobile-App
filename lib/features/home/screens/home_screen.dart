import 'package:flutter/material.dart';

import '../../../shared/theme/app_spacing.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../auth/data/auth_session.dart';
import '../../auth/data/models/user_response.dart';
import '../../auth/widgets/auth_primary_button_widget.dart';

// Accueil provisoire : prouve la session de bout en bout en attendant le vrai écran.
class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.authSession, super.key});

  final AuthSession authSession;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<UserResponse> _currentUser = widget.authSession
      .fetchCurrentUser();
  bool _isLoggingOut = false;

  Future<void> _logout() async {
    setState(() {
      _isLoggingOut = true;
    });
    await widget.authSession.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Accueil', style: AppTextStyles.formTitle),
              SizedBox(height: AppSpacing.md),
              FutureBuilder<UserResponse>(
                future: _currentUser,
                builder:
                    (
                      BuildContext context,
                      AsyncSnapshot<UserResponse> snapshot,
                    ) {
                      if (snapshot.hasData) {
                        return Text(
                          'Connecté en tant que ${snapshot.data!.email}',
                          style: AppTextStyles.formSubtitle,
                        );
                      }
                      if (snapshot.hasError) {
                        return Text(
                          'Impossible de charger votre profil.',
                          style: AppTextStyles.formError,
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
              ),
              const Spacer(),
              AuthPrimaryButtonWidget(
                label: 'Déconnexion',
                isLoading: _isLoggingOut,
                onPressed: _isLoggingOut ? null : _logout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
