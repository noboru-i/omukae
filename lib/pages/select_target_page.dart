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
  Position currentPosition;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  void _initLocation() async {
    try {
      var currentLocation = await Geolocator().getLastKnownPosition();
      debugPrint("lat: ${currentLocation.latitude}");
      debugPrint("lng: ${currentLocation.longitude}");
      setState(() {
        currentPosition = currentLocation;
      });
    } on PlatformException catch (e) {
      debugPrint("exception: $e");
      debugPrint("is permission denied: ${e.code == 'PERMISSION_DENIED'}");
      return null;
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

  Future<String> _distanceText() async {
    return await Geolocator()
        .distanceBetween(
            centerPosition.target.latitude,
            centerPosition.target.longitude,
            currentPosition.latitude,
            currentPosition.longitude)
        .then((distanceInMeters) {
      return (distanceInMeters / 1000.0).toStringAsFixed(2) + "km";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding:
              EdgeInsets.only(top: 12.0, right: 8.0, bottom: 12.0, left: 8.0),
          child: FutureBuilder(
            future: _distanceText(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                return Text(
                  'distance ${snapshot.data}',
                  textAlign: TextAlign.right,
                );
              } else {
                return Text(
                  'distance -',
                  textAlign: TextAlign.right,
                );
              }
            },
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
