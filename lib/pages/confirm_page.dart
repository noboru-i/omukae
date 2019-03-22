import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:geofencing/geofencing.dart';
import 'package:omukae/repository/draft_repository.dart';

class ConfirmPage extends StatefulWidget {
  @override
  _ConfirmPageState createState() => _ConfirmPageState();
}

class _ConfirmPageState extends State<ConfirmPage> {
  var geofenceState = 'N/A';
  var port = ReceivePort();
  var debugText = '';

  @override
  void initState() {
    super.initState();
    IsolateNameServer.registerPortWithName(
        port.sendPort, 'geofencing_send_port');
    port.listen((dynamic data) {
      print('Event: $data');
      setState(() {
        geofenceState = data;
        debugText += data + '\n';
      });
    });

    // async
    GeofencingManager.initialize();
  }

  static void callback(List<String> ids, Location l, GeofenceEvent e) async {
    print('Fences: $ids Location $l Event: $e');
    final SendPort send =
        IsolateNameServer.lookupPortByName('geofencing_send_port');
    send?.send(e.toString());
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
              child: Text('迎えに行く'),
            ),
            Text(debugText)
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
    draft.messageList.forEach((message) => {
          GeofencingManager.registerGeofence(
            GeofenceRegion('mtv', draft.latitude, draft.longitude,
                message.distance.toDouble(), [GeofenceEvent.enter],
                androidSettings: androidSettings),
            callback,
          )
        });
  }
}
