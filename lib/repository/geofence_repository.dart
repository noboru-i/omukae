import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class GeofenceRepository {
  Future<void> saveRegisteredGeofence(
      RegisteredGeofence registeredGeofence) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'registered_geofence', jsonEncode(registeredGeofence.toJson()));
  }

  Future<RegisteredGeofence> loadRegisteredGeofence() async {
    var prefs = await SharedPreferences.getInstance();
    var registeredGeofenceString = await prefs.getString('registered_geofence');
    if (registeredGeofenceString == null) {
      return null;
    }
    return RegisteredGeofence.fromJson(jsonDecode(registeredGeofenceString));
  }
}

class RegisteredGeofence {
  List<String> ids;

  RegisteredGeofence({
    this.ids,
  });

  RegisteredGeofence.fromJson(Map<String, dynamic> json)
      : ids = (json['ids'] as List)?.map((id) => id.toString())?.toList();

  Map<String, dynamic> toJson() => {
        'ids': ids,
      };
}
