import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/app/router.dart';
import 'package:flutter_frontend/features/auth/data/auth_api_service.dart';
import 'package:flutter_frontend/features/auth/data/auth_session.dart';
import 'package:flutter_frontend/features/auth/data/models/user_response.dart';
import 'package:flutter_frontend/features/home/theme/home_colors.dart';
import 'package:flutter_frontend/features/home/theme/home_sizes.dart';
import 'package:flutter_frontend/features/home/widgets/home_bottom_navigation_widget.dart';
import 'package:flutter_frontend/shared/theme/app_theme.dart';
import 'package:flutter_frontend/shared/widgets/content_card_widget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../support/fake_auth.dart';

void main() {
  late FakeAuthApiService api;
  late InMemoryTokenStorage storage;

  String currentRoute(GoRouter router) =>
      router.routerDelegate.currentConfiguration.last.matchedLocation;

  Finder navigationIcon(String asset) => find.byWidgetPredicate(
    (Widget widget) =>
        widget is SvgPicture &&
        widget.bytesLoader is SvgAssetLoader &&
        (widget.bytesLoader as SvgAssetLoader).assetName ==
            'assets/icons/$asset',
  );

  Map<String, Offset> navigationIconCenters(WidgetTester tester) =>
      <String, Offset>{
        for (final String asset in <String>[
          'home_map.svg',
          'home_house.svg',
          'home_scan.svg',
        ])
          asset: tester.getCenter(navigationIcon(asset)),
      };

  void expectNavigationColors(
    WidgetTester tester,
    HomeNavigationDestination? active,
  ) {
    for (final MapEntry<HomeNavigationDestination, String> entry
        in <HomeNavigationDestination, String>{
          HomeNavigationDestination.map: 'home_map.svg',
          HomeNavigationDestination.home: 'home_house.svg',
          HomeNavigationDestination.scan: 'home_scan.svg',
        }.entries) {
      final SvgPicture icon = tester.widget<SvgPicture>(
        navigationIcon(entry.value),
      );
      expect(
        icon.colorFilter,
        ColorFilter.mode(
          entry.key == active
              ? HomeColors.navigationIconActive
              : HomeColors.navigationIconInactive,
          BlendMode.srcIn,
        ),
        reason: entry.value,
      );
    }
  }

  setUpAll(() async {
    final FontLoader font = FontLoader('HomeNunito')
      ..addFont(rootBundle.load('assets/fonts/nunito/Nunito.ttf'));
    await font.load();
  });

  setUp(() {
    api = FakeAuthApiService();
    storage = InMemoryTokenStorage();
  });

  Future<AuthSession> signedInSession() async {
    final AuthSession session = AuthSession(
      authApiService: api,
      tokenStorage: storage,
    );
    await session.login(email: 'ada@example.com', password: 'MotDePasse1!');
    return session;
  }

  Future<GoRouter> pumpHome(
    WidgetTester tester,
    AuthSession session, {
    String initialLocation = AppRoutes.home,
    TextScaler textScaler = TextScaler.noScaling,
    bool disableAnimations = false,
  }) async {
    final GoRouter router = createAppRouter(
      session,
      initialLocation: initialLocation,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: textScaler,
            disableAnimations: disableAnimations,
          ),
          child: RepaintBoundary(key: const Key('home-render'), child: child!),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  for (final (String label, Offset delta, int expectedMap, int expectedScan)
      in <(String, Offset, int, int)>[
        ('left', const Offset(-70, 0), 1, 0),
        ('right', const Offset(70, 0), 0, 1),
        ('short', const Offset(25, 0), 0, 0),
        ('vertical', const Offset(0, 70), 0, 0),
      ]) {
    testWidgets('handles a $label drag in the bottom control', (
      WidgetTester tester,
    ) async {
      int mapCalls = 0;
      int scanCalls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: HomeBottomNavigationWidget(
                onMap: () async {
                  mapCalls++;
                },
                onScan: () async {
                  scanCalls++;
                },
              ),
            ),
          ),
        ),
      );
      final Finder thumb = find.byKey(const Key('home-navigation-thumb'));
      final Offset originalCenter = tester.getCenter(thumb);
      final Map<String, Offset> originalIconCenters = navigationIconCenters(
        tester,
      );

      await tester.drag(thumb, delta);
      await tester.pumpAndSettle();

      expect(mapCalls, expectedMap);
      expect(scanCalls, expectedScan);
      expect(tester.getCenter(thumb), originalCenter);
      expect(navigationIconCenters(tester), originalIconCenters);
      expect(tester.takeException(), isNull);
    });
  }

  for (final String label in <String>['Carte', 'Scanner un déchet']) {
    testWidgets('animates toward $label before calling back', (
      WidgetTester tester,
    ) async {
      int calls = 0;
      final Completer<void> destination = Completer<void>();
      Future<void> open() {
        calls++;
        return destination.future;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: HomeBottomNavigationWidget(onMap: open, onScan: open),
            ),
          ),
        ),
      );
      final Finder thumb = find.byKey(const Key('home-navigation-thumb'));
      final Offset originalCenter = tester.getCenter(thumb);
      final double direction = label == 'Carte' ? -1 : 1;
      final Map<String, Offset> originalIconCenters = navigationIconCenters(
        tester,
      );
      final Stack track = tester.widget<Stack>(
        find
            .descendant(
              of: find.byType(HomeBottomNavigationWidget),
              matching: find.byType(Stack),
            )
            .first,
      );
      expect(track.children.first, isA<Positioned>());
      expect(track.children.last, isA<Row>());
      expectNavigationColors(tester, HomeNavigationDestination.home);

      await tester.tap(find.byTooltip(label));
      await tester.pump();
      expectNavigationColors(tester, HomeNavigationDestination.home);
      await tester.pump(HomeSizes.selectionDuration ~/ 2);
      expect(calls, 0);
      final double offset = tester.getCenter(thumb).dx - originalCenter.dx;
      expect(offset * direction, greaterThan(0));
      expect(offset.abs(), lessThan(HomeSizes.navigationSlot));
      expect(navigationIconCenters(tester), originalIconCenters);
      expectNavigationColors(
        tester,
        direction < 0
            ? HomeNavigationDestination.map
            : HomeNavigationDestination.scan,
      );
      await tester.pump(HomeSizes.selectionDuration ~/ 2);
      await tester.pump(const Duration(milliseconds: 16));
      expect(calls, 1);
      expect(
        tester.getCenter(thumb).dx,
        closeTo(originalCenter.dx + direction * HomeSizes.navigationSlot, 0.01),
      );
      expect(navigationIconCenters(tester), originalIconCenters);

      destination.complete();
      await tester.pumpAndSettle();
      expect(tester.getCenter(thumb), originalCenter);
      expect(navigationIconCenters(tester), originalIconCenters);
      expectNavigationColors(tester, HomeNavigationDestination.home);
      expect(tester.takeException(), isNull);
    });
  }

  for (final String label in <String>['Carte', 'Scanner un déchet']) {
    testWidgets('keeps uncovered icons black during the movement to $label', (
      WidgetTester tester,
    ) async {
      final Completer<void> destination = Completer<void>();
      Future<void> open() => destination.future;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: HomeBottomNavigationWidget(onMap: open, onScan: open),
            ),
          ),
        ),
      );
      await tester.tap(find.byTooltip(label));
      await tester.pump();
      expectNavigationColors(tester, HomeNavigationDestination.home);
      await tester.pump(const Duration(milliseconds: 35));
      expectNavigationColors(tester, null);
      await tester.pump(const Duration(milliseconds: 65));
      expectNavigationColors(
        tester,
        label == 'Carte'
            ? HomeNavigationDestination.map
            : HomeNavigationDestination.scan,
      );
      await tester.pumpAndSettle();
      destination.complete();
      await tester.pumpAndSettle();
      expectNavigationColors(tester, HomeNavigationDestination.home);
    });
  }

  for (final String route in <String>[
    AppRoutes.seasonalVegetables,
    AppRoutes.sortingGuide,
    AppRoutes.community,
    AppRoutes.map,
    AppRoutes.wasteScan,
    AppRoutes.settings,
  ]) {
    if (route == AppRoutes.map || route == AppRoutes.wasteScan) {
      testWidgets('slides the navigation down after two seconds on $route', (
        WidgetTester tester,
      ) async {
        final GoRouter router = await pumpHome(
          tester,
          await signedInSession(),
          initialLocation: route,
        );
        final Finder thumb = find.byKey(const Key('home-navigation-thumb'));
        expect(currentRoute(router), route);
        expect(thumb, findsOneWidget);
        final Offset messagePosition = tester.getCenter(
          find.text('Page en construction ⚙️'),
        );
        final Offset originalCenter = tester.getCenter(thumb);
        await tester.pump(HomeSizes.destinationVisibilityDuration);
        expect(thumb, findsOneWidget);
        await tester.pump();
        await tester.pump(HomeSizes.navigationExitDuration ~/ 2);
        expect(tester.getCenter(thumb).dy, greaterThan(originalCenter.dy));
        await tester.pumpAndSettle();
        expect(thumb, findsNothing);
        expect(
          tester.getCenter(find.text('Page en construction ⚙️')),
          messagePosition,
        );
        await tester.tap(find.byTooltip('Retour à l\'accueil'));
        await tester.pumpAndSettle();
        expect(currentRoute(router), AppRoutes.home);
        expect(thumb, findsOneWidget);
        await tester.pump(HomeSizes.destinationVisibilityDuration);
        expect(thumb, findsOneWidget);
      });
    }

    testWidgets('opens the protected construction route $route', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await pumpHome(
        tester,
        await signedInSession(),
        initialLocation: route,
      );

      expect(currentRoute(router), route);
      expect(find.text('Page en construction ⚙️'), findsOneWidget);
    });

    testWidgets('protects construction route $route without a session', (
      WidgetTester tester,
    ) async {
      final AuthSession session = AuthSession(
        authApiService: api,
        tokenStorage: storage,
      );
      final GoRouter router = await pumpHome(
        tester,
        session,
        initialLocation: route,
      );

      expect(currentRoute(router), AppRoutes.landing);
      expect(find.text('Page en construction ⚙️'), findsNothing);
    });
  }

  testWidgets('returns home when a destination was opened directly', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await pumpHome(
      tester,
      await signedInSession(),
      initialLocation: AppRoutes.map,
    );

    await tester.tap(find.byTooltip('Retour à l\'accueil'));
    await tester.pumpAndSettle();

    expect(currentRoute(router), AppRoutes.home);
    expect(find.text('Ada'), findsOneWidget);
  });

  testWidgets(
    'shows the first name and static eco card of the signed-in user',
    (WidgetTester tester) async {
      await pumpHome(tester, await signedInSession());

      expect(find.text('Ada'), findsOneWidget);
      expect(find.text('Eco-baroudeur'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('190 / 500'), findsOneWidget);
      expect(
        tester.getSize(find.byKey(const Key('home-eco-progress'))).width,
        closeTo(329, 0.01),
      );
      expect(api.accessTokensUsed, <String>['access-1']);
    },
  );

  testWidgets('opens settings and returns without reloading the profile', (
    WidgetTester tester,
  ) async {
    await pumpHome(tester, await signedInSession());

    final GoRouter router = GoRouter.of(tester.element(find.text('Ada')));
    await tester.tap(find.byTooltip('Réglages'));
    await tester.pumpAndSettle();

    expect(find.text('Page en construction ⚙️'), findsOneWidget);
    expect(currentRoute(router), AppRoutes.settings);
    await tester.tap(find.byTooltip('Retour à l\'accueil'));
    await tester.pumpAndSettle();
    expect(find.text('Ada'), findsOneWidget);
    expect(api.accessTokensUsed, <String>['access-1']);
  });

  testWidgets('explains when the profile cannot be loaded', (
    WidgetTester tester,
  ) async {
    api.onFetchCurrentUser = (_) async =>
        throw const AuthApiException('Erreur', statusCode: 500);

    await pumpHome(tester, await signedInSession());

    expect(find.text('Impossible de charger votre profil.'), findsOneWidget);
  });

  testWidgets('sends visitors without a session back to the landing screen', (
    WidgetTester tester,
  ) async {
    final AuthSession session = AuthSession(
      authApiService: api,
      tokenStorage: storage,
    );
    await session.restore();

    await pumpHome(tester, session);

    expect(find.text('Green\'Hub'), findsOneWidget);
    expect(api.accessTokensUsed, isEmpty);
  });

  Future<void> checkDestinationAndReturn(
    WidgetTester tester,
    GoRouter router,
    String route,
  ) async {
    await tester.pumpAndSettle();
    expect(find.text('Page en construction ⚙️'), findsOneWidget);
    expect(currentRoute(router), route);
    await tester.tap(find.byTooltip('Retour à l\'accueil'));
    await tester.pumpAndSettle();
    expect(currentRoute(router), AppRoutes.home);
    expect(find.text('Ada'), findsOneWidget);
    expect(api.accessTokensUsed, <String>['access-1']);
  }

  Future<void> captureNavigation(WidgetTester tester, String name) async {
    if (!const bool.fromEnvironment('CAPTURE_NAVIGATION')) {
      return;
    }
    final bool previousDisableShadows = debugDisableShadows;
    try {
      debugDisableShadows = false;
      await tester.pump();
      await expectLater(
        find.byKey(const Key('home-render')),
        matchesGoldenFile(
          Uri.file(
            '${Directory.systemTemp.path}/greenhub-navigation-$name.png',
          ),
        ),
      );
    } finally {
      debugDisableShadows = previousDisableShadows;
    }
  }

  for (final (String label, String route, double direction)
      in <(String, String, double)>[
        ('Carte', AppRoutes.map, -1),
        ('Scanner un déchet', AppRoutes.wasteScan, 1),
      ]) {
    testWidgets(
      'animates then displays the bar for exactly two seconds on $route',
      (WidgetTester tester) async {
        final GoRouter router = await pumpHome(tester, await signedInSession());
        final Finder thumb = find.byKey(const Key('home-navigation-thumb'));
        final Finder control = find.byType(HomeBottomNavigationWidget);
        final State<StatefulWidget> originalState = tester.state(control);
        final Offset originalCenter = tester.getCenter(thumb);
        final String captureName = direction < 0 ? 'map' : 'scan';
        await captureNavigation(tester, 'home-$captureName');

        await tester.tap(find.byTooltip(label));
        await tester.pump();
        await tester.pump(HomeSizes.selectionDuration ~/ 2);
        expect(currentRoute(router), AppRoutes.home);
        final double offset = tester.getCenter(thumb).dx - originalCenter.dx;
        expect(offset * direction, greaterThan(0));
        expect(offset.abs(), lessThan(HomeSizes.navigationSlot));
        await captureNavigation(tester, 'moving-$captureName');

        await tester.pump(HomeSizes.selectionDuration ~/ 2);
        await tester.pump(const Duration(milliseconds: 16));
        await tester.pump();
        await tester.pump();
        expect(currentRoute(router), route);
        expect(find.text('Page en construction ⚙️'), findsOneWidget);
        expect(tester.state(control), same(originalState));
        expect(
          tester.getCenter(thumb).dx,
          closeTo(
            originalCenter.dx + direction * HomeSizes.navigationSlot,
            0.01,
          ),
        );
        await captureNavigation(tester, 'destination-$captureName');

        await tester.pump(const Duration(milliseconds: 1999));
        expect(thumb, findsOneWidget);
        final Offset messagePosition = tester.getCenter(
          find.text('Page en construction ⚙️'),
        );
        final Offset stationaryCenter = tester.getCenter(thumb);
        await tester.pump(const Duration(milliseconds: 1));
        expect(thumb, findsOneWidget);
        await tester.pump();
        await tester.pump(HomeSizes.navigationExitDuration ~/ 2);
        expect(tester.getCenter(thumb).dy, greaterThan(stationaryCenter.dy));
        expect(
          tester.getCenter(find.text('Page en construction ⚙️')),
          messagePosition,
        );
        await captureNavigation(tester, 'exiting-$captureName');
        await tester.pumpAndSettle();
        expect(thumb, findsNothing);
        await captureNavigation(tester, 'hidden-$captureName');

        await tester.tap(find.byTooltip('Retour à l\'accueil'));
        await tester.pumpAndSettle();
        expect(currentRoute(router), AppRoutes.home);
        expect(tester.getCenter(thumb), originalCenter);
        expect(tester.state(control), same(originalState));
        expect(api.accessTokensUsed, <String>['access-1']);
      },
    );

    testWidgets(
      'keeps the home bar visible after returning early from $route',
      (WidgetTester tester) async {
        final GoRouter router = await pumpHome(tester, await signedInSession());
        await tester.tap(find.byTooltip(label));
        await tester.pumpAndSettle();
        expect(currentRoute(router), route);
        await tester.tap(find.byTooltip('Retour à l\'accueil'));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 3));
        expect(currentRoute(router), AppRoutes.home);
        expect(find.byKey(const Key('home-navigation-thumb')), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  Future<void> startNavigationExit(WidgetTester tester) async {
    await tester.pump(HomeSizes.destinationVisibilityDuration);
    await tester.pump();
    await tester.pump(HomeSizes.navigationExitDuration ~/ 2);
  }

  for (final String route in <String>[AppRoutes.map, AppRoutes.wasteScan]) {
    testWidgets('restores the bar when returning during the exit from $route', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await pumpHome(
        tester,
        await signedInSession(),
        initialLocation: route,
      );
      final Finder control = find.byType(HomeBottomNavigationWidget);
      final double originalTop = tester.getTopLeft(control).dy;
      await startNavigationExit(tester);
      expect(tester.getTopLeft(control).dy, greaterThan(originalTop));
      await tester.tap(find.byTooltip('Retour à l\'accueil'));
      await tester.pumpAndSettle();
      expect(currentRoute(router), AppRoutes.home);
      expect(tester.getTopLeft(control).dy, closeTo(originalTop, 0.01));
      await tester.pump(const Duration(seconds: 3));
      expect(control, findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'hides $route immediately after its delay with reduced motion',
      (WidgetTester tester) async {
        await pumpHome(
          tester,
          await signedInSession(),
          initialLocation: route,
          disableAnimations: true,
        );
        final Finder thumb = find.byKey(const Key('home-navigation-thumb'));
        expect(thumb, findsOneWidget);
        await tester.pump(HomeSizes.destinationVisibilityDuration);
        expect(thumb, findsNothing);
        expect(
          tester
              .widget<AnimatedSlide>(
                find.byKey(const Key('home-navigation-exit')),
              )
              .offset,
          Offset.zero,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final (Size viewport, double bottomInset) in <(Size, double)>[
    (const Size(320, 568), 0),
    (const Size(393, 852), 34),
  ]) {
    testWidgets(
      'moves the entire bar offscreen with bottom inset $bottomInset',
      (WidgetTester tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = viewport;
        tester.view.padding = FakeViewPadding(top: 24, bottom: bottomInset);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetPadding);
        await pumpHome(
          tester,
          await signedInSession(),
          initialLocation: AppRoutes.map,
        );
        final Finder control = find.byType(HomeBottomNavigationWidget);
        final Rect originalRect = tester.getRect(control);
        final Map<String, Offset> originalIcons = navigationIconCenters(tester);
        await startNavigationExit(tester);
        final Rect movingRect = tester.getRect(control);
        expect(movingRect.top, greaterThan(originalRect.top));
        final double deltaY = movingRect.top - originalRect.top;
        for (final MapEntry<String, Offset> entry in originalIcons.entries) {
          final Offset iconCenter = tester.getCenter(navigationIcon(entry.key));
          expect(iconCenter.dx, closeTo(entry.value.dx, 0.01));
          expect(iconCenter.dy, closeTo(entry.value.dy + deltaY, 0.01));
        }
        await tester.pump(
          HomeSizes.navigationExitDuration ~/ 2 -
              const Duration(milliseconds: 1),
        );
        expect(
          tester.getRect(control).top,
          greaterThanOrEqualTo(viewport.height),
        );
        await tester.pumpAndSettle();
        expect(control, findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'restarts the display delay when the destination changes during exit',
    (WidgetTester tester) async {
      final GoRouter router = await pumpHome(
        tester,
        await signedInSession(),
        initialLocation: AppRoutes.map,
      );
      await startNavigationExit(tester);
      router.go(AppRoutes.wasteScan);
      await tester.pumpAndSettle();
      final Finder control = find.byType(HomeBottomNavigationWidget);
      expect(currentRoute(router), AppRoutes.wasteScan);
      expect(control, findsOneWidget);
      expect(
        tester
            .widget<AnimatedSlide>(
              find.byKey(const Key('home-navigation-exit')),
            )
            .offset,
        Offset.zero,
      );
      await tester.pump(HomeSizes.navigationExitDuration);
      expect(control, findsOneWidget);
      await tester.pump(HomeSizes.destinationVisibilityDuration);
      await tester.pumpAndSettle();
      expect(control, findsNothing);
    },
  );

  testWidgets('cancels the exit safely when the session ends', (
    WidgetTester tester,
  ) async {
    final AuthSession session = await signedInSession();
    final GoRouter router = await pumpHome(
      tester,
      session,
      initialLocation: AppRoutes.map,
    );
    await startNavigationExit(tester);
    await session.logout();
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));
    expect(currentRoute(router), AppRoutes.landing);
    expect(find.byType(HomeBottomNavigationWidget), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('does not finish the exit after its shell is disposed', (
    WidgetTester tester,
  ) async {
    await pumpHome(
      tester,
      await signedInSession(),
      initialLocation: AppRoutes.map,
    );
    await startNavigationExit(tester);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('ignores the opposite icon while the selection is animating', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await pumpHome(tester, await signedInSession());
    await tester.tap(find.byTooltip('Carte'));
    await tester.pump();
    await tester.pump(HomeSizes.selectionDuration ~/ 2);
    await tester.tap(find.byTooltip('Scanner un déchet'));
    await checkDestinationAndReturn(tester, router, AppRoutes.map);
  });

  testWidgets('does not navigate after disposal during an animation', (
    WidgetTester tester,
  ) async {
    int calls = 0;
    Future<void> open() async {
      calls++;
    }

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeBottomNavigationWidget(onMap: open, onScan: open),
        ),
      ),
    );
    await tester.tap(find.byTooltip('Carte'));
    await tester.pump();
    await tester.pump(HomeSizes.selectionDuration ~/ 2);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(HomeSizes.selectionDuration);
    expect(calls, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancels selection when another page opens during movement', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await pumpHome(tester, await signedInSession());
    await tester.tap(find.byTooltip('Carte'));
    await tester.pump();
    await tester.pump(HomeSizes.selectionDuration ~/ 2);
    unawaited(router.push<void>(AppRoutes.community));
    await tester.pumpAndSettle();
    expect(currentRoute(router), AppRoutes.community);
    expect(find.byKey(const Key('home-navigation-thumb')), findsNothing);
    await tester.tap(find.byTooltip('Retour à l\'accueil'));
    await tester.pumpAndSettle();
    expect(currentRoute(router), AppRoutes.home);
    await tester.pump(const Duration(seconds: 3));
    expect(currentRoute(router), AppRoutes.home);
    expect(find.byKey(const Key('home-navigation-thumb')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancels selection when the session ends during movement', (
    WidgetTester tester,
  ) async {
    final AuthSession session = await signedInSession();
    final GoRouter router = await pumpHome(tester, session);
    await tester.tap(find.byTooltip('Carte'));
    await tester.pump();
    await tester.pump(HomeSizes.selectionDuration ~/ 2);
    await session.logout();
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));
    expect(currentRoute(router), AppRoutes.landing);
    expect(find.byKey(const Key('home-navigation-thumb')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final double direction in <double>[-1, 1]) {
    testWidgets(
      'opens exactly once when a drag already reached edge $direction',
      (WidgetTester tester) async {
        int calls = 0;
        final Completer<void> destination = Completer<void>();
        Future<void> open() {
          calls++;
          return destination.future;
        }

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: HomeBottomNavigationWidget(onMap: open, onScan: open),
              ),
            ),
          ),
        );
        final Finder thumb = find.byKey(const Key('home-navigation-thumb'));
        final Offset originalCenter = tester.getCenter(thumb);
        final Map<String, Offset> originalIconCenters = navigationIconCenters(
          tester,
        );
        final TestGesture gesture = await tester.startGesture(
          tester.getCenter(navigationIcon('home_house.svg')),
        );
        await gesture.moveBy(Offset(direction * 25, 0));
        await tester.pump();
        expect(navigationIconCenters(tester), originalIconCenters);
        await gesture.moveBy(Offset(direction * 80, 0));
        await tester.pump();
        await tester.pump();
        expect(
          tester.getCenter(thumb).dx,
          closeTo(
            originalCenter.dx + direction * HomeSizes.navigationSlot,
            0.01,
          ),
        );
        expect(navigationIconCenters(tester), originalIconCenters);
        expect(calls, 0);
        await gesture.up();
        await tester.pumpAndSettle();
        expect(calls, 1);
        expect(navigationIconCenters(tester), originalIconCenters);
        destination.complete();
        await tester.pumpAndSettle();
        expect(tester.getCenter(thumb), originalCenter);
        expect(navigationIconCenters(tester), originalIconCenters);
      },
    );
  }

  testWidgets('skips the movement when animations are disabled', (
    WidgetTester tester,
  ) async {
    int calls = 0;
    final Completer<void> destination = Completer<void>();
    Future<void> open() {
      calls++;
      return destination.future;
    }

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: Center(
              child: HomeBottomNavigationWidget(onMap: open, onScan: open),
            ),
          ),
        ),
      ),
    );
    final Finder thumb = find.byKey(const Key('home-navigation-thumb'));
    final Offset originalCenter = tester.getCenter(thumb);
    await tester.tap(find.byTooltip('Carte'));
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(
      tester.getCenter(thumb).dx,
      closeTo(originalCenter.dx - HomeSizes.navigationSlot, 0.01),
    );
    destination.complete();
    await tester.pumpAndSettle();
    expect(tester.getCenter(thumb), originalCenter);
  });

  for (final MapEntry<String, String> entry in <String, String>{
    'Légumes de saison': AppRoutes.seasonalVegetables,
    'Guide de tri': AppRoutes.sortingGuide,
    'Les posts de la communauté': AppRoutes.community,
  }.entries) {
    testWidgets('opens ${entry.key} and returns home', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await pumpHome(tester, await signedInSession());
      await tester.ensureVisible(find.text(entry.key));
      await tester.pumpAndSettle();
      await tester.tap(find.text(entry.key));
      await checkDestinationAndReturn(tester, router, entry.value);
    });
  }

  for (final MapEntry<String, String> entry in <String, String>{
    'Carte': AppRoutes.map,
    'Scanner un déchet': AppRoutes.wasteScan,
  }.entries) {
    testWidgets('opens ${entry.value} by tapping its icon', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await pumpHome(tester, await signedInSession());
      await tester.tap(find.byTooltip(entry.key));
      await checkDestinationAndReturn(tester, router, entry.value);
    });
  }

  for (final (Offset delta, String route) in <(Offset, String)>[
    (const Offset(-70, 0), AppRoutes.map),
    (const Offset(70, 0), AppRoutes.wasteScan),
  ]) {
    testWidgets('opens $route by sliding the home button', (
      WidgetTester tester,
    ) async {
      final GoRouter router = await pumpHome(tester, await signedInSession());
      final Finder thumb = find.byKey(const Key('home-navigation-thumb'));
      final Offset originalCenter = tester.getCenter(thumb);
      await tester.drag(thumb, delta);
      await checkDestinationAndReturn(tester, router, route);
      expect(tester.getCenter(thumb), originalCenter);
    });
  }

  testWidgets('cancels a drag and keeps the home button centered', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await pumpHome(tester, await signedInSession());
    final Finder thumb = find.byKey(const Key('home-navigation-thumb'));
    final Offset originalCenter = tester.getCenter(thumb);
    final TestGesture gesture = await tester.startGesture(originalCenter);
    await gesture.moveBy(const Offset(-70, 0));
    await tester.pump();
    await gesture.cancel();
    await tester.pumpAndSettle();

    expect(currentRoute(router), AppRoutes.home);
    expect(tester.getCenter(thumb), originalCenter);
  });

  testWidgets('does not push two destinations on rapid repeated taps', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await pumpHome(tester, await signedInSession());
    await tester.tap(find.byTooltip('Carte'));
    await tester.tap(find.byTooltip('Carte'));
    await checkDestinationAndReturn(tester, router, AppRoutes.map);
  });

  testWidgets('keeps navigation usable while the profile is loading', (
    WidgetTester tester,
  ) async {
    final Completer<UserResponse> pending = Completer<UserResponse>();
    api.onFetchCurrentUser = (_) => pending.future;
    final GoRouter router = await pumpHome(tester, await signedInSession());
    expect(find.text('Accueil'), findsOneWidget);
    await tester.tap(find.byTooltip('Carte'));
    await tester.pumpAndSettle();
    expect(currentRoute(router), AppRoutes.map);
    pending.complete(connectedUser());
    await tester.pumpAndSettle();
  });

  testWidgets('falls back to Accueil for an empty first name', (
    WidgetTester tester,
  ) async {
    api.onFetchCurrentUser = (_) async => connectedUser(firstName: '  ');
    await pumpHome(tester, await signedInSession());
    expect(find.text('Accueil'), findsOneWidget);
  });

  testWidgets('redirects when the session is cleared on a destination', (
    WidgetTester tester,
  ) async {
    final AuthSession session = await signedInSession();
    final GoRouter router = await pumpHome(tester, session);
    await tester.tap(find.byTooltip('Carte'));
    await tester.pumpAndSettle();
    await session.logout();
    await tester.pumpAndSettle();
    expect(currentRoute(router), AppRoutes.landing);
    expect(find.text('Page en construction ⚙️'), findsNothing);
  });

  for (final Size viewport in <Size>[
    const Size(393, 852),
    const Size(320, 568),
    const Size(1024, 768),
  ]) {
    testWidgets(
      'renders at ${viewport.width.toInt()}x${viewport.height.toInt()} without overflow',
      (WidgetTester tester) async {
        final bool previousDisableShadows = debugDisableShadows;
        if (const bool.fromEnvironment('CAPTURE_HOME')) {
          debugDisableShadows = false;
        }
        try {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = viewport;
          tester.view.padding = const FakeViewPadding(top: 24, bottom: 34);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetPadding);
          await pumpHome(tester, await signedInSession());

          expect(tester.takeException(), isNull);
          final Finder vegetables = find.ancestor(
            of: find.text('Légumes de saison'),
            matching: find.byType(ContentCardWidget),
          );
          final Finder guide = find.ancestor(
            of: find.text('Guide de tri'),
            matching: find.byType(ContentCardWidget),
          );
          expect(
            tester.getSize(vegetables).height,
            tester.getSize(guide).height,
          );
          expect(
            tester.getRect(find.byTooltip('Carte')).bottom,
            lessThanOrEqualTo(viewport.height - 34),
          );
          await tester.ensureVisible(find.text('Les posts de la communauté'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          if (const bool.fromEnvironment('CAPTURE_HOME')) {
            await expectLater(
              find.byKey(const Key('home-render')),
              matchesGoldenFile(
                Uri.file(
                  '${Directory.systemTemp.path}/greenhub-home-${viewport.width.toInt()}.png',
                ),
              ),
            );
          }
        } finally {
          debugDisableShadows = previousDisableShadows;
        }
      },
    );
  }

  testWidgets('supports long names and enlarged text on a small screen', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    const String longName = 'Alexandrine Marie-Christine de la communauté';
    api.onFetchCurrentUser = (_) async => connectedUser(firstName: longName);
    await pumpHome(
      tester,
      await signedInSession(),
      textScaler: TextScaler.linear(1.5),
    );
    expect(find.text(longName), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Les posts de la communauté'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders every local Figma asset with its intended geometry', (
    WidgetTester tester,
  ) async {
    await pumpHome(tester, await signedInSession());
    for (final MapEntry<String, Size> entry in <String, Size>{
      'home_settings.svg': const Size(29.6251, 30.3333),
      'home_eco_decoration.svg': const Size(183, 167),
      'home_level_badge.svg': const Size(43, 44),
      'home_carrot.svg': const Size(30, 30),
      'home_recycle.svg': const Size(27, 27),
      'home_community.svg': const Size(22.75, 21.5012),
      'home_map.svg': const Size(17.5001, 21.5),
      'home_scan.svg': const Size(20.5, 20.5),
      'home_navigation_thumb.svg': const Size(42, 43),
      'home_house.svg': const Size(19.5002, 20.5),
      'home_separator.svg': const Size(323, 4),
    }.entries) {
      final String path = 'assets/icons/${entry.key}';
      expect((await rootBundle.load(path)).lengthInBytes, greaterThan(0));
      final Finder asset = find.byWidgetPredicate((Widget widget) {
        if (widget is SvgPicture && widget.bytesLoader is SvgAssetLoader) {
          return (widget.bytesLoader as SvgAssetLoader).assetName == path;
        }
        return false;
      });
      expect(asset, findsOneWidget, reason: path);
      final Size rendered = tester.getSize(asset);
      expect(rendered.width, closeTo(entry.value.width, 0.01), reason: path);
      expect(rendered.height, closeTo(entry.value.height, 0.01), reason: path);
    }
  });
}
