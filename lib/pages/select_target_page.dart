import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:omukae/pages/select_notification_page.dart';
import 'package:omukae/repository/draft_repository.dart';
import 'package:omukae/ui/distance_label.dart';

class SelectTargetPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('目的地の選択'),
      ),
      body: SafeArea(
        child: MapContainer(),
      ),
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
  LocationData currentPosition;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  void _initLocation() async {
    try {
      debugPrint("_initLocation");
      var location = Location();
      if (!await location.hasPermission()) {
        return;
      }
      var currentLocation = await location.getLocation();
      debugPrint("lat: ${currentLocation.latitude}");
      debugPrint("lng: ${currentLocation.longitude}");
      setState(() {
        currentPosition = currentLocation;
      });
    } on PlatformException catch (e) {
      debugPrint("exception: $e");
      debugPrint("is permission denied: ${e.code == 'PERMISSION_DENIED'}");
      return;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding:
              EdgeInsets.only(top: 12.0, right: 8.0, bottom: 12.0, left: 8.0),
          child: DistanceLabel(
            targetPosition: centerPosition == null
                ? null
                : LocationData.fromMap({
                    "latitude": centerPosition.target.latitude,
                    "longitude": centerPosition.target.longitude,
                  }),
          ),
        ),
        Expanded(
          child: currentPosition == null
              ? Center(
                  child: Text('現在地取得中'),
                )
              : Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          currentPosition.latitude,
                          currentPosition.longitude,
                        ),
                        zoom: 13,
                      ),
                      myLocationEnabled: true,
                      onMapCreated: (GoogleMapController controller) {
                        mapController = controller;
                      },
                      onCameraMove: (CameraPosition position) {
                        setState(() {
                          centerPosition = position;
                        });
                      },
                    ),
                    // shadow
                    Center(
                      child: Icon(
                        Icons.location_searching,
                        size: 40,
                        color: Colors.black.withOpacity(0.1),
                      ),
                    ),
                    Center(
                      child: Icon(
                        Icons.location_searching,
                        size: 36,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
        ),
        RaisedButton(
          padding: EdgeInsets.all(20.0),
          onPressed: _moveToNext,
          color: Colors.blue[800],
          child: const Text(
            '地図の中心に目的地を設定',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
