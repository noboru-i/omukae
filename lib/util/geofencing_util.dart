import 'dart:async';

import 'package:geofencing/geofencing.dart';
import 'package:omukae/repository/draft_repository.dart';
import 'package:omukae/repository/geofence_repository.dart';
import 'package:omukae/util/geofence_trigger.dart';

class GeofencingUtil {
  Future<bool> registerGeofencing() async {
    await _removeOldGeofence();
    var ids = await _register();
    await _saveGeofence(ids);
    return true;
  }

  Future<void> _removeOldGeofence() async {
    var geofence = await GeofenceRepository().loadRegisteredGeofence();
    if (geofence == null) {
      return;
    }

    geofence.ids.forEach((id) async {
      await GeofencingManager.removeGeofenceById(id);
    });
  }

  Future<List<String>> _register() async {
    var draft = await DraftRepository().loadCurrentDraft();
    var ids = List<String>();

    var androidSettings = AndroidGeofencingSettings(
      initialTrigger: <GeofenceEvent>[GeofenceEvent.enter],
      loiteringDelay: 0,
    );
    for (var i = 0; i < draft.messageList.length; i++) {
      var message = draft.messageList[i];
      print('index=$i, value=$message');
      ids.add(i.toString());
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
    return ids;
  }

  Future<void> _saveGeofence(List<String> ids) async {
    var value = RegisteredGeofence(ids: ids);
    await GeofenceRepository().saveRegisteredGeofence(value);
  }
}
