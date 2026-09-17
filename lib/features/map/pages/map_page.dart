import 'package:flutter/material.dart';
import 'package:flutter_frontend/features/map/services/map_manager.dart';
import 'package:flutter_frontend/shared/shared.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final MapManager _mapManager = MapManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final position = await _mapManager.getPosition();
      if (position == null) {
        return;
      }
      _mapController.move(position['latlng'], position['zoom']);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mapTilerKey = dotenv.env["MAPTILER_API_KEY"];

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(47.3941, 0.6848),
              initialZoom: 15,
              onPositionChanged: (position, hasGesture) async {
                if (!hasGesture) return;
                await _mapManager.savePosition(
                  position.center.latitude,
                  position.center.longitude,
                  position.zoom,
                );
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://api.maptiler.com/maps/streets-v4/{z}/{x}/{y}.png?key=$mapTilerKey',
                userAgentPackageName: 'com.example.mon_app'
              )
            ],
          ),
          Positioned(
            top: ResponsiveUtils.topSpacing(context),
            left: ResponsiveUtils.horizontalSpacing(context),
            child: FABButtonWidget(icon: Icons.chevron_left, onPressed: () {}),
          ),

          Positioned(
            top: ResponsiveUtils.topSpacing(context),
            right: ResponsiveUtils.horizontalSpacing(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FABButtonWidget(icon: Icons.search, onPressed: () {}),
                const SizedBox(height: 12),
                FABButtonWidget(
                  icon: Icons.filter_alt_outlined,
                  onPressed: _loadVelibStations,
                ),
              ],
            ),
          ),

          Positioned(
            bottom: ResponsiveUtils.bottomSpacing(context),
            right: ResponsiveUtils.horizontalSpacing(context),
            child: FABButtonWidget(
              icon: Icons.my_location,
              onPressed: () async {
                final position = await _mapManager.getCurrentPosition();
                if (position == null || !mounted) return;
                _mapController.move(position['latlng'], position['zoom']);
              },
            ),
          ),
        ],
      ),
    );
  }
}