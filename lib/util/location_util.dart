import 'dart:async';

import 'package:location/location.dart';
import 'package:omukae/repository/gps_cache_repository.dart';

class LocationUtil {
  Location location;

  LocationUtil() {
    location = Location();
  }

  Future<LocationData> getLastKnownLocation() async {
    var cacheLocation = await GpsCacheRepository().loadGpsCache();
    if (cacheLocation != null) {
      return LocationData.fromMap({
        'latitude': cacheLocation.latitude,
        'longitude': cacheLocation.longitude,
      });
    }

    return null;
  }

  Future<LocationData> getLocation() async {
    var currentLocation = await location.getLocation();
    await GpsCacheRepository().saveGpsCache(GpsCache(
      latitude: currentLocation.latitude,
      longitude: currentLocation.longitude,
    ));

    return currentLocation;
  }
}
