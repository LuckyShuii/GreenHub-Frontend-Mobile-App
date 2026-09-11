import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapManager {
  Future<Map<String, dynamic>?> getPosition() async {
    final currentPosition = await getCurrentPosition();
    if(currentPosition != null){
      return currentPosition;
    }
    final lastSavePosition = await getLastSavePosition();
    if(lastSavePosition != null){
      return lastSavePosition;
    }
    return {
      'latlang': LatLng(47.3941, 0.6848),
      'zoom' : 15,
    };
  }

  Future<Map<String, dynamic>?> getCurrentPosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();

    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
    }

    if(permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    Position position = await Geolocator.getCurrentPosition();
    return {
      'latlang': LatLng(position.latitude, position.longitude),
      'zoom' : 15,
    };
  }

  Future<void> savePosition(
      double latitude,
      double longitude,
      double zoom
      ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('latitude', latitude);
    await prefs.setDouble('longitude', longitude);
    await prefs.setDouble('zoom', zoom);
  }

  Future<Map<String, dynamic>?> getLastSavePosition() async {
    final prefs = await SharedPreferences.getInstance();
    final latitude = prefs.getDouble('latitude');
    final longitude = prefs.getDouble('longitude');
    final zoom = prefs.getDouble('zoom');

    if (latitude == null || longitude == null || zoom == null) {
      return null;
    }

    return {
      'latlang': LatLng(latitude, longitude),
      'zoom' : zoom,
    };
  }
}