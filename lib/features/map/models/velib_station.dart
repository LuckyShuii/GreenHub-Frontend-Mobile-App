import 'package:flutter_frontend/features/map/models/map_marker_type.dart';
import 'package:flutter_frontend/features/map/models/map_point.dart';
import 'package:latlong2/latlong.dart';

class VelibStation implements MapPoint {
  final String name;
  final LatLng position;
  final int availableBikes;
  final int mechanicalBikes;
  final int electricBikes;
  final int availableStands;

  VelibStation({
    required this.name,
    required this.position,
    required this.availableBikes,
    required this.mechanicalBikes,
    required this.electricBikes,
    required this.availableStands,
  });

  @override
  MapMarkerType get markerType => MapMarkerType.velib;

  factory VelibStation.fromJson(Map<String, dynamic> json) {
    final coordinates = json['coordonnees_geo'] as Map<String, dynamic>;

    return VelibStation(
      name: json['name']?.toString() ?? '',
      position: LatLng(
          (coordinates['lat'] as num).toDouble(),
          (coordinates['lon'] as num).toDouble()
      ),
      availableBikes: (json['numbikesavailable'] as num?)?.toInt() ?? 0,
      mechanicalBikes: (json['mechanical'] as num?)?.toInt() ?? 0,
      electricBikes: (json['ebike'] as num?)?.toInt() ?? 0,
      availableStands: (json['numdocksavailable'] as num?)?.toInt() ?? 0,
    );
  }
}