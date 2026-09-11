import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapManager {
  Future<Position?> getCurrentPosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();

    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
    }

    if(permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition();
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

  Future<Map<String, double>?> getLastSavePosition() async {
    final prefs = await SharedPreferences.getInstance();
    final latitude = prefs.getDouble('latitude');
    final longitude = prefs.getDouble('longitude');
    final zoom = prefs.getDouble('zoom');

    if (latitude == null || longitude == null || zoom == null) {
      return null;
    }

    return {
      'latitude' : latitude,
      'longitude' : longitude,
      'zoom' : zoom,
    };
  }
}