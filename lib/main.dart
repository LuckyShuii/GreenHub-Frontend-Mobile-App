import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'features/auth/data/auth_api_service.dart';
import 'features/auth/data/auth_session.dart';
import 'features/auth/data/token_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AuthSession authSession = AuthSession(
    authApiService: AuthApiService(),
    tokenStorage: SecureTokenStorage(),
  );
  await authSession.restore();

  runApp(GreenHubApp(authSession: authSession));
}
