import 'dart:convert';

import 'package:omukae/data/gps_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GpsCacheRepository {
  Future<void> saveGpsCache(GpsData gpsData) async {
    var prefs = await SharedPreferences.getInstance();
    if (gpsData == null) {
      await prefs.remove('gps_cache');
      return;
    }
    await prefs.setString('gps_cache', jsonEncode(gpsData.toJson()));
  }

  Future<GpsData> loadGpsCache() async {
    var prefs = await SharedPreferences.getInstance();
    var gpsDataString = prefs.getString('gps_cache');
    if (gpsDataString == null) {
      return null;
    }
    return GpsData.fromJson(jsonDecode(gpsDataString));
  }
}
