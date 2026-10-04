import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/home_sizes.dart';
import 'home_bottom_navigation_widget.dart';

class HomeNavigationShellWidget extends StatefulWidget {
  const HomeNavigationShellWidget({
    required this.child,
    required this.destination,
    required this.onMap,
    required this.onScan,
    this.isActive = true,
    super.key,
  });

  final Widget child;
  final HomeNavigationDestination destination;
  final Future<void> Function() onMap;
  final Future<void> Function() onScan;
  final bool isActive;

  @override
  State<HomeNavigationShellWidget> createState() =>
      _HomeNavigationShellWidgetState();
}

class _HomeNavigationShellWidgetState extends State<HomeNavigationShellWidget> {
  Timer? _hideTimer;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    _updateVisibility();
  }

  @override
  void didUpdateWidget(HomeNavigationShellWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.destination != widget.destination ||
        oldWidget.isActive != widget.isActive) {
      _updateVisibility();
    }
  }

  void _updateVisibility() {
    _hideTimer?.cancel();
    _visible = true;
    if (widget.isActive &&
        widget.destination != HomeNavigationDestination.home) {
      _hideTimer = Timer(HomeSizes.destinationVisibilityDuration, () {
        if (mounted) {
          setState(() {
            _visible = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        widget.child,
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(bottom: HomeSizes.navigationBottomGap),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Visibility(
                  visible: _visible && widget.isActive,
                  maintainState: true,
                  child: HomeBottomNavigationWidget(
                    destination: widget.destination,
                    enabled:
                        widget.isActive &&
                        widget.destination == HomeNavigationDestination.home,
                    onMap: widget.onMap,
                    onScan: widget.onScan,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
