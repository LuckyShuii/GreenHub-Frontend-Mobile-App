import 'package:flutter/material.dart';
import 'package:flutter_frontend/features/map/models/velib_station.dart';
import 'package:flutter_frontend/features/map/services/map_manager.dart';
import 'package:flutter_frontend/features/map/services/velib_manager.dart';
import 'package:flutter_frontend/shared/shared.dart';
import 'package:flutter_frontend/shared/utils/responsive_utils.dart';
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
  final VelibManager _velibManager = VelibManager();

  List<VelibStation> _stations = [];
  bool _isLoadingStations = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final position = await _mapManager.getPosition();
      if (position == null) {
        return;
      }
      final latLng = position['latlng'] as LatLng;
      final zoom = position['zoom'] as double;

      _mapController.move(latLng, zoom);
    });
  }

  Future<void> _loadVelibStations() async {
    if (_isLoadingStations) return;

    setState(() {
      _isLoadingStations = true;
    });

    try {
      final bounds = _mapController.camera.visibleBounds;
      final stations = await _velibManager.getStations(
        topLeft: bounds.northWest,
        bottomRight: bounds.southEast,
        referencePoint: _mapController.camera.center,
        limit: 10,
      );
      if (!mounted) return;
      setState(() {
        _stations = stations;
      });
    } catch (e) {
      debugPrint('Erreur chargement Vélib: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingStations = false;
      });
    }
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
                urlTemplate:
                    'https://api.maptiler.com/maps/streets-v4/{z}/{x}/{y}.png?key=$mapTilerKey',
                userAgentPackageName: 'com.example.mon_app',
              ),
              MarkerLayer(
                markers: _stations.map((station) {
                  return Marker(
                    point: station.position,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.pedal_bike,
                      color: Colors.blue,
                      size: 30,
                    ),
                  );
                }).toList(),
              ),
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