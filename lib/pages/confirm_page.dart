import 'dart:async';
import 'dart:collection';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:geofencing/geofencing.dart';
import 'package:geolocator/geolocator.dart';
import 'package:omukae/repository/draft_repository.dart';
import 'package:omukae/util/local_notification_util.dart';

void callback(List<String> ids, Location l, GeofenceEvent e) async {
  print('callback Fences: $ids Location $l Event: $e');
  var maxId = ids.map((s) => int.parse(s)).reduce(max);

  var repository = DraftRepository();
  var draft = await repository.loadCurrentDraft();
  var message = draft.messageList[maxId];

  var notificationUtil = LocalNotificationUtil();
  notificationUtil.notify(title: 'omukae', body: 'message: ' + message.text);

  final SendPort send =
      IsolateNameServer.lookupPortByName('geofencing_send_port');
  send?.send(maxId);
}

class ConfirmPage extends StatefulWidget {
  @override
  _ConfirmPageState createState() => _ConfirmPageState();
}

class _ConfirmPageState extends State<ConfirmPage> {
  var port = ReceivePort();
  var log = ListQueue<String>();

  // TODO
  var geolocator = Geolocator();
  var locationOptions =
      LocationOptions(accuracy: LocationAccuracy.best, distanceFilter: 0);
  StreamSubscription<Position> positionStream;

  @override
  void initState() {
    super.initState();
    IsolateNameServer.registerPortWithName(
        port.sendPort, 'geofencing_send_port');
    port.listen((dynamic data) async {
      print('listen: $data');
      var repository = DraftRepository();
      var draft = await repository.loadCurrentDraft();
      var message = draft.messageList[data];

//      var notificationUtil = LocalNotificationUtil();
//      notificationUtil.notify(
//          title: 'omukae', body: 'message: ' + message.text);

      setState(() {
        log.add('notify ${message.text}');
      });
    });

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

    initPlatformState();
  }

  @override
  void dispose() {
    super.dispose();
    positionStream.cancel();
    positionStream = null;
  }

  Future<void> initPlatformState() async {
    print('Initializing...');
    await GeofencingManager.initialize();
    print('Initialization done');
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
      GeofencingManager.registerGeofence(
        GeofenceRegion(
          i.toString(),
          draft.latitude,
          draft.longitude,
          message.distance.toDouble(),
          [GeofenceEvent.enter],
          androidSettings: androidSettings,
        ),
        callback,
      );
    }
    setState(() {
      log.add('geofence is added.');
    });
  }
}
