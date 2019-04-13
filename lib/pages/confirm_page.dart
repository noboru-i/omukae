import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:omukae/data/gps_data.dart';
import 'package:omukae/repository/draft_repository.dart';
import 'package:omukae/ui/distance_label.dart';
import 'package:omukae/util/location_util.dart';
import 'package:share/share.dart';
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
  GpsData currentPosition;
  Draft draft;
  Set<Marker> markers = Set();

  StreamSubscription<GpsData> positionStream;

  GoogleMapController mapController;

  @override
  void initState() {
    super.initState();

    _initLocation();

    positionStream = LocationUtil()
        .onLocationChanged()
        .listen((GpsData currentLocation) async {
      if (draft == null) {
        return;
      }
      setState(() {
        currentPosition = currentLocation;
      });
    });
  }

  void _initLocation() async {
    try {
      var currentLocation = await LocationUtil().getLastKnownLocation();
      setState(() {
        currentPosition = currentLocation;
      });
    } on PlatformException catch (e) {
      debugPrint("exception: $e");
      debugPrint("is permission denied: ${e.code == 'PERMISSION_DENIED'}");
      return;
    }
    var repository = DraftRepository();
    var draft = await repository.loadCurrentDraft();
    setState(() {
      this.draft = draft;
      markers.add(Marker(
        markerId: MarkerId('to'),
        position: draft.target.toLatLng(),
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
            targetPosition: draft?.target,
            currentPosition: currentPosition,
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
              target: currentPosition.toLatLng(),
              zoom: 13,
            ),
            myLocationEnabled: true,
            markers: markers,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;

              var west = min(currentPosition.longitude, draft.target.longitude);
              var east = max(currentPosition.longitude, draft.target.longitude);
              var north = min(currentPosition.latitude, draft.target.latitude);
              var south = max(currentPosition.latitude, draft.target.latitude);
              var southwest = LatLng(south, west);
              var northeast = LatLng(north, east);
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
    Share.share('uuid: ' + draft.notifyUuid);
  }
}
