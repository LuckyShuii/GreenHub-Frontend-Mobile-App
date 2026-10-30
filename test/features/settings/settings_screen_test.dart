import 'package:flutter/material.dart';
import 'package:flutter_frontend/app/router.dart';
import 'package:flutter_frontend/features/auth/data/auth_api_service.dart';
import 'package:flutter_frontend/features/auth/data/auth_session.dart';
import 'package:flutter_frontend/features/auth/data/models/profile_update_request.dart';
import 'package:flutter_frontend/features/auth/data/models/user_response.dart';
import 'package:flutter_frontend/shared/theme/app_theme.dart';
import 'package:flutter_frontend/shared/theme/app_colors.dart';
import 'package:flutter_frontend/shared/widgets/app_notification_host_widget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../support/fake_auth.dart';

void main() {
  late FakeAuthApiService api;

  setUp(() {
    api = FakeAuthApiService();
  });

  Future<({GoRouter router, WidgetTester tester})> pumpRoute(
    WidgetTester tester,
    String route,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final InMemoryTokenStorage storage = InMemoryTokenStorage();
    final AuthSession session = AuthSession(
      authApiService: api,
      tokenStorage: storage,
    );
    await session.login(email: 'ada@example.com', password: 'MotDePasse1!');
    final GoRouter router = createAppRouter(session, initialLocation: route);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: router,
        builder: (context, child) => AppNotificationHost(child: child!),
      ),
    );
    await tester.pumpAndSettle();
    return (router: router, tester: tester);
  }

  testWidgets('shows every settings section and profile actions', (
    WidgetTester tester,
  ) async {
    await pumpRoute(tester, AppRoutes.settings);

    expect(find.text('Paramètre'), findsOneWidget);
    expect(find.text('Information personnelle'), findsNothing);
    expect(find.text('Supprimer mon compte'), findsNothing);
    expect(find.text('Notification'), findsNothing);
    expect(find.text('Autorisations'), findsNothing);
    expect(find.text('FAQ'), findsNothing);
    expect(find.text('Mention légale'), findsNothing);
    for (final String section in <String>[
      'Profil',
      'Préférences',
      'Confidentialité',
      'Aide & Support',
      'À propos',
    ]) {
      await tester.scrollUntilVisible(find.text(section), 300);
      expect(find.text(section), findsOneWidget);
    }
    await tester.scrollUntilVisible(find.text('Déconnexion'), 300);
    expect(find.text('Déconnexion'), findsOneWidget);
  });

  testWidgets('opens and saves personal information', (
    WidgetTester tester,
  ) async {
    api.onFetchCurrentUser = (_) async => connectedUser();
    api.onUpdateCurrentUser = (_, ProfileUpdateRequest request) async =>
        UserResponse(
          id: connectedUser().id,
          firstName: request.firstName,
          lastName: request.lastName,
          email: request.email,
          username: request.username,
          postalCode: request.postalCode,
          createdAt: connectedUser().createdAt,
        );
    final ({GoRouter router, WidgetTester tester}) app = await pumpRoute(
      tester,
      AppRoutes.settings,
    );

    await tester.tap(find.byKey(const Key('settings-section-Profil')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Information personnelle'));
    await tester.pumpAndSettle();
    expect(find.text('Profil'), findsOneWidget);
    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('Pseudonyme'), findsOneWidget);
    expect(find.text('ada'), findsOneWidget);
    await tester.tap(find.byTooltip('Modifier le profil'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Grace');
    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('profile-username-field')),
        matching: find.byType(TextFormField),
      ),
      'grace_hopper',
    );
    await tester.tap(find.byTooltip('Enregistrer'));
    await tester.pumpAndSettle();

    expect(api.profileUpdates, hasLength(1));
    expect(api.profileUpdates.single.firstName, 'Grace');
    expect(api.profileUpdates.single.username, 'grace_hopper');
    expect(find.text('grace_hopper'), findsOneWidget);
    expect(
      app.router.routerDelegate.currentConfiguration.last.matchedLocation,
      AppRoutes.profile,
    );
  });

  testWidgets('toggles sections independently from their collapsed state', (
    WidgetTester tester,
  ) async {
    await pumpRoute(tester, AppRoutes.settings);

    await tester.tap(find.byKey(const Key('settings-section-Profil')));
    await tester.pumpAndSettle();
    expect(find.text('Information personnelle'), findsOneWidget);
    await tester.tap(find.byKey(const Key('settings-section-Préférences')));
    await tester.pumpAndSettle();
    expect(find.text('Notification'), findsOneWidget);
    expect(find.text('Information personnelle'), findsOneWidget);
    await tester.tap(find.byKey(const Key('settings-section-Profil')));
    await tester.pumpAndSettle();
    expect(find.text('Information personnelle'), findsNothing);
    expect(find.text('Notification'), findsOneWidget);
  });

  testWidgets('flips profile and logout icons vertically', (
    WidgetTester tester,
  ) async {
    await pumpRoute(tester, AppRoutes.settings);

    for (final String asset in <String>[
      'settings_profile.svg',
      'settings_logout.svg',
    ]) {
      final Transform icon = tester.widget<Transform>(
        find.byKey(Key('settings-icon-$asset')),
      );
      expect(icon.transform.entry(0, 0), 1);
      expect(icon.transform.entry(1, 1), -1);
    }
  });

  testWidgets('keeps settings destructive actions white with red borders', (
    WidgetTester tester,
  ) async {
    await pumpRoute(tester, AppRoutes.settings);
    await tester.tap(find.byKey(const Key('settings-section-Profil')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Déconnexion'), 300);

    for (final String label in <String>[
      'Supprimer mon compte',
      'Déconnexion',
    ]) {
      final Container surface = tester.widget<Container>(
        find
            .ancestor(of: find.text(label), matching: find.byType(Container))
            .first,
      );
      final BoxDecoration decoration = surface.decoration! as BoxDecoration;
      expect(decoration.color, AppColors.white);
      expect((decoration.border! as Border).top.color, AppColors.erreur);
    }
  });

  testWidgets('validates the username before saving', (
    WidgetTester tester,
  ) async {
    await pumpRoute(tester, AppRoutes.profile);
    await tester.tap(find.byTooltip('Modifier le profil'));
    await tester.pumpAndSettle();
    final Finder username = find.descendant(
      of: find.byKey(const Key('profile-username-field')),
      matching: find.byType(TextFormField),
    );

    await tester.enterText(username, '   ');
    await tester.tap(find.byTooltip('Enregistrer'));
    await tester.pumpAndSettle();
    expect(find.text('Veuillez renseigner votre pseudonyme.'), findsOneWidget);
    expect(api.profileUpdates, isEmpty);

    await tester.enterText(username, List<String>.filled(51, 'a').join());
    await tester.tap(find.byTooltip('Enregistrer'));
    await tester.pumpAndSettle();
    expect(
      find.text('Le pseudonyme ne doit pas dépasser 50 caractères.'),
      findsOneWidget,
    );
    expect(api.profileUpdates, isEmpty);
  });

  testWidgets('keeps the editor open when the username is already taken', (
    WidgetTester tester,
  ) async {
    api.onUpdateCurrentUser = (_, _) async => throw const AuthApiException(
      'Ce pseudonyme est déjà utilisé.',
      statusCode: 409,
    );
    final ({GoRouter router, WidgetTester tester}) app = await pumpRoute(
      tester,
      AppRoutes.profile,
    );
    await tester.tap(find.byTooltip('Modifier le profil'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('profile-username-field')),
        matching: find.byType(TextFormField),
      ),
      'taken',
    );
    await tester.tap(find.byTooltip('Enregistrer'));
    await tester.pumpAndSettle();

    expect(find.text('Ce pseudonyme est déjà utilisé.'), findsOneWidget);
    expect(
      app.router.routerDelegate.currentConfiguration.last.matchedLocation,
      AppRoutes.profileEdit,
    );
  });

  testWidgets('requires a valid matching password before submission', (
    WidgetTester tester,
  ) async {
    await pumpRoute(tester, AppRoutes.passwordEdit);

    final Finder submit = find.widgetWithText(
      FilledButton,
      'Changer votre mot de passe',
    );
    expect(tester.widget<FilledButton>(submit).onPressed, isNull);
    await tester.enterText(
      find.byKey(const Key('profile-new-password-field')),
      'NouveauMotDePasse1!',
    );
    await tester.enterText(find.byType(TextFormField).last, 'Different1!');
    expect(tester.widget<FilledButton>(submit).onPressed, isNull);
    await tester.enterText(
      find.byType(TextFormField).last,
      'NouveauMotDePasse1!',
    );
    await tester.pump();
    expect(tester.widget<FilledButton>(submit).onPressed, isNotNull);
  });

  testWidgets('submits a valid matching password', (WidgetTester tester) async {
    await pumpRoute(tester, AppRoutes.passwordEdit);
    const String password = 'NouveauMotDePasse1!';
    await tester.enterText(
      find.byKey(const Key('profile-new-password-field')),
      password,
    );
    await tester.enterText(find.byType(TextFormField).last, password);
    await tester.pump();
    await tester.tap(
      find.widgetWithText(FilledButton, 'Changer votre mot de passe'),
    );
    await tester.pumpAndSettle();

    expect(api.passwordChanges, hasLength(1));
    expect(api.passwordChanges.single.newPassword, password);
  });

  testWidgets('requires confirmation before deleting the account', (
    WidgetTester tester,
  ) async {
    await pumpRoute(tester, AppRoutes.deleteAccount);
    await tester.pumpAndSettle();

    final OutlinedButton deleteButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Supprimer mon compte'),
    );
    expect(
      deleteButton.style!.backgroundColor!.resolve(<WidgetState>{}),
      AppColors.white,
    );
    expect(
      deleteButton.style!.side!.resolve(<WidgetState>{})!.color,
      AppColors.erreur,
    );
    await tester.tap(find.text('Supprimer mon compte'));
    await tester.pumpAndSettle();
    expect(find.text('Supprimer définitivement'), findsOneWidget);
    expect(api.deletedAccounts, isEmpty);
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    expect(api.deletedAccounts, isEmpty);
  });

  testWidgets('deletes the account after explicit confirmation', (
    WidgetTester tester,
  ) async {
    final InMemoryTokenStorage storage = InMemoryTokenStorage();
    final AuthSession session = AuthSession(
      authApiService: api,
      tokenStorage: storage,
    );
    await session.login(email: 'ada@example.com', password: 'MotDePasse1!');
    final GoRouter router = createAppRouter(
      session,
      initialLocation: AppRoutes.deleteAccount,
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: router,
        builder: (context, child) => AppNotificationHost(child: child!),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer mon compte'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer définitivement'));
    await tester.pumpAndSettle();

    expect(api.deletedAccounts, <String>['access-1']);
    expect(
      router.routerDelegate.currentConfiguration.last.matchedLocation,
      AppRoutes.landing,
    );
    expect(storage.refreshToken, isNull);
  });
}
