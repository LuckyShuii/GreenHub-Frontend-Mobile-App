import 'package:flutter_frontend/features/map/models/map_marker_type.dart';
import 'package:latlong2/latlong.dart';

abstract class MapPoint {
  LatLng get position;
  MapMarkerType get markerType;
}