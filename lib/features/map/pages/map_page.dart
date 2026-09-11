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
      appBar: AppBar(title: const Text("Map")),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(47.3941, 0.6848),
          initialZoom: 15,
        ),
        children: [
          TileLayer(
              urlTemplate: 'https://api.maptiler.com/maps/streets-v4/{z}/{x}/{y}.png?key=$mapTilerKey',
              userAgentPackageName: 'com.example.mon_app'
          )
        ],
      ),
      floatingActionButton: FABButtonWidget(
        onPressed: () async {
          final position = await _mapManager.getCurrentPosition();
          if (position == null) {
            return;
          }
          _mapController.move(position['latlng'], position['zoom']);
        },
        icon: Icons.my_location,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}