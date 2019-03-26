import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:omukae/repository/draft_repository.dart';
import 'package:omukae/util/geofencing_util.dart';
import 'package:omukae/util/local_notification_util.dart';

class ConfirmPage extends StatefulWidget {
  @override
  _ConfirmPageState createState() => _ConfirmPageState();
}

class _ConfirmPageState extends State<ConfirmPage> {
  var log = ListQueue<String>();
  Position currentPosition;

  var geolocator = Geolocator();
  StreamSubscription<Position> positionStream;

  GoogleMapController mapController;

  @override
  void initState() {
    super.initState();

    // initialize for request permission
    LocalNotificationUtil();

    _initLocation();

    var locationOptions = LocationOptions(
      accuracy: LocationAccuracy.best,
      distanceFilter: 10,
    );
    positionStream = geolocator
        .getPositionStream(locationOptions)
        .listen((Position _position) async {
      print(_position == null
          ? 'Unknown'
          : '${_position.latitude.toString()}, ${_position.longitude.toString()}');

      var repository = DraftRepository();
      var draft = await repository.loadCurrentDraft();
      double distanceInMeters = await Geolocator().distanceBetween(
          draft.latitude,
          draft.longitude,
          _position.latitude,
          _position.longitude);
      print('distance: $distanceInMeters meter');
      setState(() {
        log.add('distance: $distanceInMeters meter');
        while (log.length > 15) {
          log.removeFirst();
        }
      });
    });
  }

  void _initLocation() async {
    try {
      var currentLocation = await Geolocator()
          .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
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

  @override
  void dispose() {
    super.dispose();
    positionStream.cancel();
    positionStream = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('通知の確認'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(log != null && log.isNotEmpty
              ? log.reduce((value, element) => value + '\n' + element)
              : ''),
          Expanded(
            child: currentPosition == null
                ? Center(
                    child: Text('現在地取得中'),
                  )
                : GoogleMap(
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

                      // TODO show map includes from and to
                    },
                  ),
          ),
          RaisedButton(
            padding: EdgeInsets.all(20.0),
            color: Colors.blue[800],
            onPressed: () async {
              var result = await GeofencingUtil().registerGeofencing();
              setState(() {
                log.add(result
                    ? 'geofence is added.'
                    : 'adding geofence is failed.');
              });
            },
            child: Text(
              '通知を設定する',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
