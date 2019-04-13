import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class GpsData {
  double latitude;
  double longitude;

  GpsData(
    this.latitude,
    this.longitude,
  );

  GpsData.fromLocation(LocationData data) {
    latitude = data.latitude;
    longitude = data.longitude;
  }

  GpsData.fromCameraPosition(CameraPosition data) {
    latitude = data.target.latitude;
    longitude = data.target.longitude;
  }

  GpsData.fromJson(Map<String, dynamic> json)
      : latitude = json['latitude'],
        longitude = json['longitude'];

  LatLng toLatLng() => LatLng(latitude, longitude);

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}
