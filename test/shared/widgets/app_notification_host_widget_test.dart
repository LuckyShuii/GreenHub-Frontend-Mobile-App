import 'package:flutter/material.dart';
import 'package:flutter_frontend/shared/services/app_notification_service.dart';
import 'package:flutter_frontend/shared/theme/app_colors.dart';
import 'package:flutter_frontend/shared/theme/app_theme.dart';
import 'package:flutter_frontend/shared/widgets/app_notification_host_widget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpHost(
    WidgetTester tester,
    AppNotificationService controller, {
    Widget child = const SizedBox.expand(),
  }) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AppNotificationHost(controller: controller, child: child),
      ),
    );
  }

  Color notificationColor(WidgetTester tester, AppNotificationType type) {
    final Container notification = tester.widget<Container>(
      find.byKey(Key('app-notification-${type.name}')),
    );
    return (notification.decoration! as BoxDecoration).color!;
  }

  Finder notificationSlideTransition(int id) {
    return find
        .ancestor(
          of: find.byKey(Key('app-notification-$id')),
          matching: find.byType(SlideTransition),
        )
        .first;
  }

  testWidgets('uses the semantic color for each notification type', (
    WidgetTester tester,
  ) async {
    final AppNotificationService controller = AppNotificationService();
    await pumpHost(tester, controller);

    controller.showInfo('Information');
    controller.showSuccess('Succès');
    controller.showError('Erreur');
    await tester.pump(const Duration(milliseconds: 300));

    expect(notificationColor(tester, AppNotificationType.info), AppColors.info);
    expect(
      notificationColor(tester, AppNotificationType.success),
      AppColors.succes,
    );
    expect(
      notificationColor(tester, AppNotificationType.error),
      AppColors.erreur,
    );
    expect(
      tester.widget<Text>(find.text('Erreur')).style?.decoration,
      TextDecoration.none,
    );

    controller.reset();
    await tester.pump();
    controller.dispose();
  });

  testWidgets('slides in from the top and reverses after five seconds', (
    WidgetTester tester,
  ) async {
    final AppNotificationService controller = AppNotificationService();
    await pumpHost(tester, controller);

    controller.showInfo('Information temporaire');
    await tester.pump();

    SlideTransition transition = tester.widget<SlideTransition>(
      notificationSlideTransition(0),
    );
    expect(transition.position.value.dy, lessThan(0));

    await tester.pump(const Duration(milliseconds: 300));
    transition = tester.widget<SlideTransition>(notificationSlideTransition(0));
    expect(transition.position.value, Offset.zero);

    await tester.pump(const Duration(milliseconds: 4699));
    expect(find.text('Information temporaire'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 150));
    transition = tester.widget<SlideTransition>(notificationSlideTransition(0));
    expect(transition.position.value.dy, lessThan(0));

    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('Information temporaire'), findsNothing);
    controller.dispose();
  });

  testWidgets('stays fixed while the page underneath scrolls', (
    WidgetTester tester,
  ) async {
    final AppNotificationService controller = AppNotificationService();
    await pumpHost(
      tester,
      controller,
      child: Scaffold(
        body: ListView.builder(
          itemCount: 50,
          itemBuilder: (BuildContext context, int index) {
            return SizedBox(height: 60, child: Text('Élément $index'));
          },
        ),
      ),
    );

    controller.showSuccess('Position fixe');
    await tester.pump(const Duration(milliseconds: 300));
    final Finder notification = find.text('Position fixe');
    final double initialTop = tester.getTopLeft(notification).dy;

    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pump();

    expect(tester.getTopLeft(notification).dy, initialTop);
    controller.reset();
    await tester.pump();
    controller.dispose();
  });

  testWidgets('shows three items and advances the FIFO sequentially', (
    WidgetTester tester,
  ) async {
    final AppNotificationService controller = AppNotificationService();
    await pumpHost(tester, controller);

    for (final String message in <String>['Une', 'Deux', 'Trois', 'Quatre']) {
      controller.showInfo(message);
    }
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(controller.visibleNotifications.length, 3);
    expect(controller.pendingCount, 1);
    expect(find.text('Quatre'), findsNothing);

    await tester.pump(const Duration(milliseconds: 4700));
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      controller.visibleNotifications.map(
        (AppNotification notification) => notification.message,
      ),
      <String>['Deux', 'Trois', 'Quatre'],
    );
    expect(controller.pendingCount, 0);

    await tester.pump(const Duration(milliseconds: 4999));
    expect(find.text('Deux'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Deux'), findsNothing);

    controller.reset();
    await tester.pump();
    controller.dispose();
  });

  testWidgets('dismisses upward and fills the free slot from the queue', (
    WidgetTester tester,
  ) async {
    final AppNotificationService controller = AppNotificationService();
    await pumpHost(tester, controller);

    for (final String message in <String>['Une', 'Deux', 'Trois', 'Quatre']) {
      controller.showInfo(message);
    }
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.drag(
      find.byKey(const Key('app-notification-0')),
      const Offset(0, -100),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Une'), findsNothing);
    expect(find.text('Quatre'), findsOneWidget);
    expect(controller.visibleNotifications.length, 3);

    controller.reset();
    await tester.pump();
    controller.dispose();
  });
}
