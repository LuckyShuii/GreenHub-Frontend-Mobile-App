import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../shared/theme/app_radii.dart';
import '../../../shared/theme/app_sizes.dart';
import '../theme/home_colors.dart';
import '../theme/home_shadows.dart';
import '../theme/home_sizes.dart';

enum HomeNavigationDestination { home, map, scan }

class HomeBottomNavigationWidget extends StatefulWidget {
  const HomeBottomNavigationWidget({
    required this.onMap,
    required this.onScan,
    this.destination = HomeNavigationDestination.home,
    this.enabled = true,
    super.key,
  });

  final Future<void> Function() onMap;
  final Future<void> Function() onScan;
  final HomeNavigationDestination destination;
  final bool enabled;

  @override
  State<HomeBottomNavigationWidget> createState() =>
      _HomeBottomNavigationWidgetState();
}

class _HomeBottomNavigationWidgetState
    extends State<HomeBottomNavigationWidget> {
  final GlobalKey _trackKey = GlobalKey();
  final GlobalKey _thumbPositionKey = GlobalKey();
  late double _dragOffset;
  bool _isDragging = false;
  bool _animateReset = false;
  bool _isNavigating = false;
  HomeNavigationDestination? _pendingDestination;

  double _offsetFor(HomeNavigationDestination destination) =>
      switch (destination) {
        HomeNavigationDestination.home => 0,
        HomeNavigationDestination.map => -HomeSizes.navigationSlot,
        HomeNavigationDestination.scan => HomeSizes.navigationSlot,
      };

  bool get _canSelect =>
      widget.enabled && !_isNavigating && _pendingDestination == null;

  @override
  void initState() {
    super.initState();
    _dragOffset = _offsetFor(widget.destination);
  }

  @override
  void didUpdateWidget(HomeBottomNavigationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.destination != widget.destination ||
        (oldWidget.enabled && !widget.enabled)) {
      _dragOffset = _offsetFor(widget.destination);
      _isDragging = false;
      _pendingDestination = null;
      _animateReset = widget.destination == HomeNavigationDestination.home;
    }
  }

  double _renderedOffset() {
    final RenderBox? track =
        _trackKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? thumb =
        _thumbPositionKey.currentContext?.findRenderObject() as RenderBox?;
    if (track == null || thumb == null) {
      return _dragOffset;
    }
    final double centerLeft =
        HomeSizes.navigationSlot +
        (HomeSizes.navigationSlot - AppSizes.minTouchTarget) / 2;
    return thumb.localToGlobal(Offset.zero, ancestor: track).dx - centerLeft;
  }

  void _select(HomeNavigationDestination destination) {
    if (!_canSelect) {
      return;
    }
    final double target = _offsetFor(destination);
    final bool alreadyAtTarget = (_renderedOffset() - target).abs() < 0.01;
    final bool disableAnimations = MediaQuery.disableAnimationsOf(context);
    setState(() {
      _pendingDestination = destination;
      _dragOffset = target;
      _isDragging = false;
      _animateReset = false;
    });
    if (alreadyAtTarget || disableAnimations) {
      _onMovementEnd();
    }
  }

  void _onMovementEnd() {
    final HomeNavigationDestination? destination = _pendingDestination;
    if (destination == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          _pendingDestination == destination &&
          (_renderedOffset() - _offsetFor(destination)).abs() < 0.01) {
        _completeSelection();
      }
    });
  }

  Future<void> _completeSelection() async {
    final HomeNavigationDestination? destination = _pendingDestination;
    if (destination == null || _isNavigating) {
      return;
    }
    setState(() {
      _pendingDestination = null;
      _isNavigating = true;
    });
    try {
      if (destination == HomeNavigationDestination.map) {
        await widget.onMap();
      } else {
        await widget.onScan();
      }
    } finally {
      if (mounted) {
        _isNavigating = false;
        _reset();
      }
    }
  }

  void _reset() {
    setState(() {
      _dragOffset = 0;
      _isDragging = false;
      _pendingDestination = null;
      _animateReset = true;
    });
  }

  void _finishDrag(DragEndDetails details) {
    if (!_isDragging) {
      return;
    }
    final double offset = _dragOffset;
    final bool committed =
        offset.abs() >= HomeSizes.navigationSlot * HomeSizes.dragThreshold;
    if (committed) {
      _select(
        offset < 0
            ? HomeNavigationDestination.map
            : HomeNavigationDestination.scan,
      );
    } else {
      _reset();
    }
  }

  Color _iconColor(
    HomeNavigationDestination destination,
    double renderedOffset,
  ) {
    final Offset circleCenter = Offset(
      renderedOffset + (HomeSizes.thumbFace - HomeSizes.thumbWidth) / 2,
      (HomeSizes.thumbFace - HomeSizes.thumbHeight) / 2,
    );
    final Offset iconCenter = Offset(_offsetFor(destination), 0);
    final double radius = HomeSizes.thumbFace / 2;
    return (iconCenter - circleCenter).distanceSquared <= radius * radius
        ? HomeColors.navigationIconActive
        : HomeColors.navigationIconInactive;
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        boxShadow: HomeShadows.navigation,
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: SizedBox(
          key: _trackKey,
          width: HomeSizes.navigationWidth,
          height: HomeSizes.navigationHeight,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: _dragOffset, end: _dragOffset),
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : _pendingDestination != null
                ? HomeSizes.selectionDuration
                : _animateReset
                ? HomeSizes.resetDuration
                : Duration.zero,
            curve: Curves.easeOutCubic,
            onEnd: _onMovementEnd,
            builder: (context, renderedOffset, child) => Stack(
              children: <Widget>[
              Positioned(
                left:
                    HomeSizes.navigationSlot +
                    (HomeSizes.navigationSlot - AppSizes.minTouchTarget) / 2 +
                    renderedOffset,
                top: (HomeSizes.navigationHeight - AppSizes.minTouchTarget) / 2,
                width: AppSizes.minTouchTarget,
                height: AppSizes.minTouchTarget,
                child: Semantics(
                  label: _dragOffset < 0
                      ? 'Carte'
                      : _dragOffset > 0
                      ? 'Scanner un d\u00e9chet'
                      : 'Accueil',
                  selected: true,
                  child: Tooltip(
                    message: 'Accueil',
                    child: GestureDetector(
                      key: const Key('home-navigation-thumb'),
                      behavior: HitTestBehavior.opaque,
                      onTap: _canSelect ? _reset : null,
                      onHorizontalDragStart: !_canSelect
                          ? null
                          : (_) {
                              setState(() {
                                _isDragging = true;
                                _animateReset = false;
                              });
                            },
                      onHorizontalDragUpdate: !_canSelect
                          ? null
                          : (DragUpdateDetails details) {
                              setState(() {
                                _dragOffset = (_dragOffset + details.delta.dx)
                                    .clamp(
                                      -HomeSizes.navigationSlot,
                                      HomeSizes.navigationSlot,
                                    );
                              });
                            },
                      onHorizontalDragEnd: _canSelect ? _finishDrag : null,
                      onHorizontalDragCancel: _canSelect ? _reset : null,
                      child: SizedBox(
                        key: _thumbPositionKey,
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Positioned(
                              left:
                                  (AppSizes.minTouchTarget -
                                      HomeSizes.thumbWidth) /
                                  2,
                              top:
                                  (AppSizes.minTouchTarget -
                                      HomeSizes.thumbHeight) /
                                  2,
                              width: HomeSizes.thumbFace,
                              height: HomeSizes.thumbFace,
                              child: const DecoratedBox(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: HomeShadows.thumb,
                                ),
                              ),
                            ),
                            SvgPicture.asset(
                              'assets/icons/home_navigation_thumb.svg',
                              width: HomeSizes.thumbWidth,
                              height: HomeSizes.thumbHeight,
                              excludeFromSemantics: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  SizedBox(
                    width: HomeSizes.navigationSlot,
                    height: HomeSizes.navigationHeight,
                    child: IconButton(
                      tooltip: 'Carte',
                      onPressed: _canSelect
                          ? () => _select(HomeNavigationDestination.map)
                          : null,
                      icon: SvgPicture.asset(
                        'assets/icons/home_map.svg',
                        width: HomeSizes.mapIconWidth,
                        height: HomeSizes.mapIconHeight,
                        colorFilter: ColorFilter.mode(
                          _iconColor(HomeNavigationDestination.map, renderedOffset),
                          BlendMode.srcIn,
                        ),
                        excludeFromSemantics: true,
                      ),
                    ),
                  ),
                  IgnorePointer(
                    child: SizedBox(
                      width: HomeSizes.navigationSlot,
                      height: HomeSizes.navigationHeight,
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/home_house.svg',
                          width: HomeSizes.homeIconWidth,
                          height: HomeSizes.homeIconHeight,
                          colorFilter: ColorFilter.mode(
                            _iconColor(HomeNavigationDestination.home, renderedOffset),
                            BlendMode.srcIn,
                          ),
                          excludeFromSemantics: true,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: HomeSizes.navigationSlot,
                    height: HomeSizes.navigationHeight,
                    child: IconButton(
                      tooltip: 'Scanner un d\u00e9chet',
                      onPressed: _canSelect
                          ? () => _select(HomeNavigationDestination.scan)
                          : null,
                      icon: SvgPicture.asset(
                        'assets/icons/home_scan.svg',
                        width: HomeSizes.scanIcon,
                        height: HomeSizes.scanIcon,
                        colorFilter: ColorFilter.mode(
                          _iconColor(HomeNavigationDestination.scan, renderedOffset),
                          BlendMode.srcIn,
                        ),
                        excludeFromSemantics: true,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}
