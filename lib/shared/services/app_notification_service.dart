import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

enum AppNotificationType { info, success, error }

@immutable
class AppNotification {
  const AppNotification({
    required this.id,
    required this.message,
    required this.type,
    this.isDismissing = false,
  });

  final int id;
  final String message;
  final AppNotificationType type;
  final bool isDismissing;

  AppNotification copyWith({bool? isDismissing}) {
    return AppNotification(
      id: id,
      message: message,
      type: type,
      isDismissing: isDismissing ?? this.isDismissing,
    );
  }
}

class AppNotificationService extends ChangeNotifier {
  AppNotificationService({
    this.displayDuration = const Duration(seconds: 5),
    this.exitDuration = const Duration(milliseconds: 300),
  });

  static const int maxVisibleNotifications = 3;
  static final AppNotificationService instance = AppNotificationService();

  final Duration displayDuration;
  final Duration exitDuration;
  final List<AppNotification> _visibleNotifications = <AppNotification>[];
  final Queue<AppNotification> _pendingNotifications = Queue<AppNotification>();

  Timer? _displayTimer;
  Timer? _exitTimer;
  int _nextId = 0;
  bool _isDisposed = false;

  List<AppNotification> get visibleNotifications =>
      List<AppNotification>.unmodifiable(_visibleNotifications);

  int get pendingCount => _pendingNotifications.length;

  int showInfo(String message) {
    return show(message, type: AppNotificationType.info);
  }

  int showSuccess(String message) {
    return show(message, type: AppNotificationType.success);
  }

  int showError(String message) {
    return show(message, type: AppNotificationType.error);
  }

  int show(String message, {required AppNotificationType type}) {
    final AppNotification notification = AppNotification(
      id: _nextId++,
      message: message,
      type: type,
    );

    if (_visibleNotifications.length < maxVisibleNotifications) {
      final bool shouldStartTimer = _visibleNotifications.isEmpty;
      _visibleNotifications.add(notification);
      notifyListeners();
      if (shouldStartTimer) {
        _startHeadTimer();
      }
    } else {
      _pendingNotifications.add(notification);
    }

    return notification.id;
  }

  void dismiss(int id) {
    final int index = _visibleNotifications.indexWhere(
      (AppNotification notification) => notification.id == id,
    );
    if (index == -1) {
      return;
    }

    final bool wasHead = index == 0;
    if (wasHead) {
      _cancelTimers();
    }
    _visibleNotifications.removeAt(index);
    _fillVisibleSlots();
    notifyListeners();

    if (wasHead) {
      _startHeadTimer();
    }
  }

  void reset() {
    _cancelTimers();
    _visibleNotifications.clear();
    _pendingNotifications.clear();
    _nextId = 0;
    notifyListeners();
  }

  void _startHeadTimer() {
    if (_visibleNotifications.isEmpty ||
        _visibleNotifications.first.isDismissing) {
      return;
    }
    _displayTimer = Timer(displayDuration, _beginHeadDismissal);
  }

  void _beginHeadDismissal() {
    if (_visibleNotifications.isEmpty) {
      return;
    }

    _visibleNotifications[0] = _visibleNotifications.first.copyWith(
      isDismissing: true,
    );
    notifyListeners();
    _exitTimer = Timer(exitDuration, _finishHeadDismissal);
  }

  void _finishHeadDismissal() {
    if (_visibleNotifications.isEmpty) {
      return;
    }
    _visibleNotifications.removeAt(0);
    _fillVisibleSlots();
    notifyListeners();
    _startHeadTimer();
  }

  void _fillVisibleSlots() {
    while (_visibleNotifications.length < maxVisibleNotifications &&
        _pendingNotifications.isNotEmpty) {
      _visibleNotifications.add(_pendingNotifications.removeFirst());
    }
  }

  void _cancelTimers() {
    _displayTimer?.cancel();
    _exitTimer?.cancel();
    _displayTimer = null;
    _exitTimer = null;
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _cancelTimers();
    super.dispose();
  }
}
