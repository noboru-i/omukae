import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:omukae/repository/draft_repository.dart';
import 'package:omukae/ui/distance_label.dart';
import 'package:uuid/uuid.dart';

class ConfirmPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('通知の確認'),
      ),
      body: _ConfirmPageInternal(),
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
        SizedBox(
          height: 100,
          child: _createListView(),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 4.0,
          ),
          child: RaisedButton(
            padding: EdgeInsets.all(10.0),
            onPressed: _onPressShare,
            color: Colors.blue[800],
            child: const Text(
              '通知を共有する',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        Expanded(
          child: _createMap(),
        ),
      ],
    );
  }

  Widget _createListView() {
    return draft == null || draft.messageList == null
        ? Container()
        : ListView.builder(
            itemCount: draft.messageList.length,
            itemBuilder: (BuildContext context, int index) => Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          draft.messageList[index].text,
                          style: Theme.of(context).textTheme.subtitle,
                        ),
                      ),
                      Text(
                        (draft.messageList[index].distance / 1000.0)
                                .toStringAsFixed(2) +
                            "km",
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                ),
          );
  }

  Widget _createMap() {
    return currentPosition == null
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
          );
  }

  Future<void> _onPressShare() async {
    // TODO save uuid into draft
    var uuid = new Uuid().v4();
    print('uuid: $uuid');
  }
}
