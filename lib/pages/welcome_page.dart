import 'package:flutter/material.dart';
import 'package:omukae/pages/select_target_page.dart';
import 'package:omukae/repository/geofence_repository.dart';
import 'package:omukae/util/geofencing_util.dart';

class WelcomePage extends StatelessWidget {
  final _geofenceSwitchKey = new GlobalKey<_GeofenceSwitchState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Omukae'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              padding: EdgeInsets.all(20.0),
              color: Colors.lightBlue[100],
              onPressed: () {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                      builder: (BuildContext context) => new SelectTargetPage(),
                    )).then((_) {
                      if (_geofenceSwitchKey.currentState != null) {
                        _geofenceSwitchKey.currentState.loadGeofence();
                      }
                });
              },
              child: Text('迎えに行く'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('通知設定'),
                _GeofenceSwitch(
                  key: _geofenceSwitchKey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GeofenceSwitch extends StatefulWidget {
  const _GeofenceSwitch({Key key}) : super(key: key);

  @override
  _GeofenceSwitchState createState() => _GeofenceSwitchState();
}

class _GeofenceSwitchState extends State<_GeofenceSwitch> {
  RegisteredGeofence registeredGeofence;

  Future<void> loadGeofence() async {
    var geofence = await GeofenceRepository().loadRegisteredGeofence();

    setState(() {
      registeredGeofence = geofence;
    });
    return;
  }

  _toggleGeofence(bool value, BuildContext context) async {
    if (!value) {
      await GeofencingUtil().removeOldGeofence();
      await loadGeofence();
      return;
    }

    bool registerSucceeded = await GeofencingUtil().registerGeofencing();
    if (!registerSucceeded) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              content: new Text('エラー'),
              actions: <Widget>[
                FlatButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            ),
      );
      return;
    }
    var geofence = await GeofenceRepository().loadRegisteredGeofence();
    var snackBar =
        SnackBar(content: Text('${geofence.ids.length}件の通知を設定しました。'));
    Scaffold.of(context).showSnackBar(snackBar);
    loadGeofence();
  }

  @override
  void initState() {
    super.initState();

    loadGeofence();
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: registeredGeofence != null && !registeredGeofence.isEmpty,
      onChanged: (bool value) {
        _toggleGeofence(value, context);
      },
    );
  }
}
