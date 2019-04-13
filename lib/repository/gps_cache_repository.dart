import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class GpsCacheRepository {
  Future<void> saveGpsCache(GpsCache gpsCache) async {
    var prefs = await SharedPreferences.getInstance();
    if (gpsCache == null) {
      await prefs.remove('gps_cache');
      return;
    }
    await prefs.setString('gps_cache', jsonEncode(gpsCache.toJson()));
  }

  Future<GpsCache> loadGpsCache() async {
    var prefs = await SharedPreferences.getInstance();
    var gpsCacheString = prefs.getString('gps_cache');
    if (gpsCacheString == null) {
      return null;
    }
    return GpsCache.fromJson(jsonDecode(gpsCacheString));
  }
}

class GpsCache {
  double latitude;
  double longitude;

  GpsCache({
    this.latitude,
    this.longitude,
  });

  GpsCache.fromJson(Map<String, dynamic> json)
      : latitude = json['latitude'],
        longitude = json['longitude'];

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}
