import 'package:geolocator/geolocator.dart';

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


}