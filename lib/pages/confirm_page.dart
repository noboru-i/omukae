import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:omukae/repository/draft_repository.dart';
import 'package:omukae/ui/distance_label.dart';

class ConfirmPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('通知の確認'),
      ),
      body: Builder(
        builder: (context) => _ConfirmPageInternal(),
      ),
    );
  }
}

class _ConfirmPageInternal extends StatefulWidget {
  @override
  _ConfirmPageInternalState createState() => _ConfirmPageInternalState();
}

class _ConfirmPageInternalState extends State<_ConfirmPageInternal> {
  Position currentPosition;
  Draft draft;
  Set<Marker> markers = Set();

  StreamSubscription<Position> positionStream;

  GoogleMapController mapController;

  @override
  void initState() {
    super.initState();

    _initLocation();

    var locationOptions = LocationOptions(
      accuracy: LocationAccuracy.best,
      distanceFilter: 10,
    );
    positionStream = Geolocator()
        .getPositionStream(locationOptions)
        .listen((Position _position) async {
      print(_position == null
          ? 'Unknown'
          : '${_position.latitude.toString()}, ${_position.longitude.toString()}');

      if (draft == null) {
        return;
      }
      setState(() {
        currentPosition = _position;
      });
    });
  }

  void _initLocation() async {
    try {
      var currentLocation = await Geolocator()
          .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        currentPosition = currentLocation;
      });
    } on PlatformException catch (e) {
      debugPrint("exception: $e");
      debugPrint("is permission denied: ${e.code == 'PERMISSION_DENIED'}");
      return null;
    }
    var repository = DraftRepository();
    var draft = await repository.loadCurrentDraft();
    setState(() {
      this.draft = draft;
      markers.add(Marker(
        markerId: MarkerId('to'),
        position: LatLng(draft.latitude, draft.longitude),
      ));
    });
  }

  @override
  void dispose() {
    super.dispose();
    positionStream.cancel();
    positionStream = null;
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
            targetPosition: draft == null
                ? null
                : Position(
                    latitude: draft.latitude,
                    longitude: draft.longitude,
                  ),
          ),
        ),
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
                  markers: markers,
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;

                    var west = min(currentPosition.latitude, draft.latitude);
                    var east = max(currentPosition.latitude, draft.latitude);
                    var southwest = LatLng(west, currentPosition.longitude);
                    var northeast = LatLng(east, draft.longitude);
                    mapController.moveCamera(CameraUpdate.newLatLngBounds(
                      LatLngBounds(
                        southwest: southwest,
                        northeast: northeast,
                      ),
                      60.0,
                    ));
                  },
                ),
        ),
      ],
    );
  }
}
