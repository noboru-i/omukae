import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:omukae/pages/select_notification_page.dart';
import 'package:omukae/repository/draft_repository.dart';

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
  CameraPosition centerPosition;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(35.685175, 139.7528),
    zoom: 13,
  );

  initLocation() async {
    try {
      var currentLocation = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
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

  _moveToNext() async {
    var draft = Draft(
      latitude: centerPosition.target.latitude,
      longitude: centerPosition.target.longitude,
    );
    await DraftRepository().saveCurrentDraft(draft);
    Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (BuildContext context) => new SelectNotificationPage(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: _kGooglePlex,
          myLocationEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            mapController = controller;
            initLocation();
          },
          onCameraMove: (CameraPosition position) {
            setState(() {
              centerPosition = position;
            });
          },
        ),
        Stack(
          children: [
            Center(
              child: Icon(
                Icons.location_searching,
                size: 36,
                color: Colors.blue,
              ),
            ),
            IgnorePointer(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                child: Container(
                  color: Colors.black.withOpacity(0),
                ),
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: const EdgeInsets.all(12.0),
              child: RaisedButton(
                onPressed: _moveToNext,
                color: Colors.blue[800],
                child: const Text(
                  '地図の中心に目的地を設定',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}
