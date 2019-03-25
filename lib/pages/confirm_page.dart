import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:geofencing/geofencing.dart';
import 'package:geolocator/geolocator.dart';
import 'package:omukae/repository/draft_repository.dart';
import 'package:omukae/util/geofence_trigger.dart';
import 'package:omukae/util/local_notification_util.dart';

class ConfirmPage extends StatefulWidget {
  @override
  _ConfirmPageState createState() => _ConfirmPageState();
}

class _ConfirmPageState extends State<ConfirmPage> {
  var log = ListQueue<String>();

  var geolocator = Geolocator();
  StreamSubscription<Position> positionStream;

  @override
  void initState() {
    super.initState();

    // initialize for request permission
    LocalNotificationUtil();

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              padding: EdgeInsets.all(20.0),
              color: Colors.lightBlue[100],
              onPressed: () {
                _registerGeofencing();
              },
              child: Text('通知を設定する'),
            ),
            Text(log != null && log.isNotEmpty
                ? log.reduce((value, element) => value + '\n' + element)
                : '')
          ],
        ),
      ),
    );
  }

  _registerGeofencing() async {
    var repository = DraftRepository();
    var draft = await repository.loadCurrentDraft();

    var androidSettings = AndroidGeofencingSettings(
      initialTrigger: <GeofenceEvent>[GeofenceEvent.enter],
      loiteringDelay: 0,
    );
    for (var i = 0; i < draft.messageList.length; i++) {
      var message = draft.messageList[i];
      print('index=$i, value=$message');
      await GeofencingManager.registerGeofence(
        GeofenceRegion(
          i.toString(),
          draft.latitude,
          draft.longitude,
          message.distance.toDouble(),
          [GeofenceEvent.enter],
          androidSettings: androidSettings,
        ),
        GeofenceTrigger.callback,
      );
    }
    setState(() {
      log.add('geofence is added.');
    });
  }
}
