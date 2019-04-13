import 'dart:async';

import 'package:location/location.dart';
import 'package:omukae/data/gps_data.dart';
import 'package:omukae/repository/gps_cache_repository.dart';

class LocationUtil {
  Location location;

  LocationUtil() {
    location = Location();
  }

  Future<GpsData> getLastKnownLocation() async {
    var cacheLocation = await GpsCacheRepository().loadGpsCache();
    if (cacheLocation != null) {
      return cacheLocation;
    }

    return null;
  }

  Future<GpsData> getLocation() async {
    var currentLocation = await location.getLocation();
    var gpsData = GpsData.fromLocation(currentLocation);
    await GpsCacheRepository().saveGpsCache(gpsData);

    return gpsData;
  }

  Stream<GpsData> onLocationChanged() {
    return location
        .onLocationChanged()
        .map((locationData) => locationData == null
            ? null
            : GpsData(
                locationData.latitude,
                locationData.longitude,
              ));
  }
}
