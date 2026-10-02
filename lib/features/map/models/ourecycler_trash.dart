import 'package:flutter_frontend/features/map/models/map_marker_type.dart';
import 'package:flutter_frontend/features/map/models/map_point.dart';
import 'package:latlong2/latlong.dart';

class OurecyclerTrash implements MapPoint {
  final String id;
  final String name;
  final String address;
  final String postal_code;
  final String city;
  final String department;
  final LatLng position;
  final double distance_km;
  final String is_dechetterie;
  final String accepted_material;
  final String links;
  final String material;

  OurecyclerTrash({
    required this.id,
    required this.name,
    required this.address,
    required this.postal_code,
    required this.city,
    required this.department,
    required this.position,
    required this.distance_km,
    required this.is_dechetterie,
    required this.accepted_material,
    required this.links,
    required this.material,
  });

  factory OurecyclerTrash.fromJson(
    Map<String, dynamic> json, {
    required String material,
  }) {
    return OurecyclerTrash(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      postal_code: json['postal_code']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      position: LatLng(
        (json['lat'] as num?)?.toDouble() ?? 0.0,
        (json['lng'] as num?)?.toDouble() ?? 0.0,
      ),
      distance_km: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      is_dechetterie: json['is_dechetterie']?.toString() ?? '',
      accepted_material: json['accepted_material']?.toString() ?? '',
      links: json['links']?.toString() ?? '',
      material: material,
    );
  }

  @override
  MapMarkerType get markerType {
    switch (material) {
      case 'verre':
        return MapMarkerType.verre;
      case 'plastique':
        return MapMarkerType.plastique;
      default:
        return MapMarkerType.dechetterie;
    }
  }
}
