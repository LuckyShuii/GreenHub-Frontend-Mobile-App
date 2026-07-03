import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mapTilerKey = dotenv.env["MAPTILER_API_KEY"];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Carte")
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(48.8566, 2.3522),
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://api.maptiler.com/maps/streets-v4/{z}/{x}/{y}.png?key=$mapTilerKey',
            userAgentPackageName: 'com.example.mon_app'
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ]),
    );
  }
}