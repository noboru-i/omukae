import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class SelectTargetPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('目的地の選択'),
      ),
      body: MapContainer(),
    );
  }
}

class MapContainer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MapContainerState();
}

class MapContainerState extends State<MapContainer> {
  GoogleMapController mapController;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(35.685175, 139.7528),
    zoom: 13,
  );

  initLocation() async {
    var location = new Location();
    try {
      var currentLocation = await location.getLocation();
      debugPrint("lat: ${currentLocation.latitude}");
      debugPrint("lng: ${currentLocation.longitude}");
      mapController.moveCamera(
        CameraUpdate.newLatLng(
          LatLng(currentLocation.latitude, currentLocation.longitude),
        ),
      );
    } on PlatformException catch (e) {
      debugPrint("exception: $e");
      debugPrint("is permission denied: ${e.code == 'PERMISSION_DENIED'}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: _kGooglePlex,
      myLocationEnabled: true,
      onMapCreated: (GoogleMapController controller) {
        mapController = controller;
        initLocation();
      },
      onCameraMove: (CameraPosition position) {
        debugPrint("lat: ${position.target.latitude}");
        debugPrint("lng: ${position.target.longitude}");
      },
    );
  }
}
