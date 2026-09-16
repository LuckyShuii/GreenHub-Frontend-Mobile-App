import 'package:flutter/material.dart';

import '../services/app_notification_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_shadows.dart';
import '../theme/app_sizes.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class AppNotificationHost extends StatefulWidget {
  const AppNotificationHost({required this.child, this.controller, super.key});

  final Widget child;
  final AppNotificationService? controller;

  static AppNotificationService of(BuildContext context) {
    final _AppNotificationScope? scope = context
        .dependOnInheritedWidgetOfExactType<_AppNotificationScope>();
    assert(scope != null, 'No AppNotificationHost found in the widget tree.');
    return scope!.controller;
  }

  @override
  State<AppNotificationHost> createState() => _AppNotificationHostState();
}

class _AppNotificationHostState extends State<AppNotificationHost> {
  late AppNotificationService _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? AppNotificationService.instance;
  }

  @override
  void didUpdateWidget(covariant AppNotificationHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    final AppNotificationService controller =
        widget.controller ?? AppNotificationService.instance;
    if (!identical(controller, _controller)) {
      _controller = controller;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AppNotificationScope(
      controller: _controller,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          widget.child,
          SafeArea(
            child: IgnorePointer(
              ignoring: false,
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.sm,
                    AppSpacing.sm,
                    AppSpacing.sm,
                    0,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: toRem(22.8125)),
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (BuildContext context, Widget? child) {
                        return _NotificationStack(controller: _controller);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppNotificationScope extends InheritedWidget {
  const _AppNotificationScope({required this.controller, required super.child});

  final AppNotificationService controller;

  @override
  bool updateShouldNotify(_AppNotificationScope oldWidget) {
    return !identical(controller, oldWidget.controller);
  }
}

class _NotificationStack extends StatelessWidget {
  const _NotificationStack({required this.controller});

  static final double _notificationHeight = toRem(3.75);
  static final double _notificationGap = AppSpacing.xs;

  final AppNotificationService controller;

  @override
  Widget build(BuildContext context) {
    final List<AppNotification> notifications = controller.visibleNotifications;
    final double stackHeight = notifications.isEmpty
        ? 0
        : notifications.length * _notificationHeight +
              (notifications.length - 1) * _notificationGap;

    return AnimatedContainer(
      key: const Key('app-notification-stack'),
      duration: controller.exitDuration,
      curve: Curves.easeInOut,
      height: stackHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          for (int index = 0; index < notifications.length; index++)
            AnimatedPositioned(
              key: ValueKey<int>(notifications[index].id),
              duration: controller.exitDuration,
              curve: Curves.easeInOut,
              top: index * (_notificationHeight + _notificationGap),
              left: 0,
              right: 0,
              height: _notificationHeight,
              child: _AppNotificationCard(
                notification: notifications[index],
                duration: controller.exitDuration,
                onDismissed: () => controller.dismiss(notifications[index].id),
              ),
            ),
        ],
      ),
    );
  }
}

class _AppNotificationCard extends StatefulWidget {
  const _AppNotificationCard({
    required this.notification,
    required this.duration,
    required this.onDismissed,
  });

  final AppNotification notification;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_AppNotificationCard> createState() => _AppNotificationCardState();
}

class _AppNotificationCardState extends State<_AppNotificationCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    final CurvedAnimation animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.25),
      end: Offset.zero,
    ).animate(animation);
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(animation);
    _animationController.forward();
  }

  @override
  void didUpdateWidget(covariant _AppNotificationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.notification.isDismissing &&
        widget.notification.isDismissing) {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = switch (widget.notification.type) {
      AppNotificationType.info => AppColors.info,
      AppNotificationType.success => AppColors.succes,
      AppNotificationType.error => AppColors.erreur,
    };

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Dismissible(
          key: Key('app-notification-${widget.notification.id}'),
          direction: DismissDirection.up,
          resizeDuration: null,
          onDismissed: (DismissDirection direction) => widget.onDismissed(),
          child: Semantics(
            liveRegion: true,
            label: widget.notification.message,
            child: Container(
              key: Key('app-notification-${widget.notification.type.name}'),
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border.all(color: AppColors.o300),
                borderRadius: BorderRadius.circular(AppRadii.md),
                boxShadow: AppShadows.md,
              ),
              child: Text(
                widget.notification.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.formInput.copyWith(
                  color: Colors.white,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
