import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geofencing/geofencing.dart';
import 'package:omukae/repository/draft_repository.dart';
import 'package:omukae/repository/geofence_repository.dart';
import 'package:omukae/util/geofence_trigger.dart';

class GeofencingUtil {
  Future<bool> registerGeofencing() async {
    await removeOldGeofence();
    var ids = await _register();
    if (ids == null || ids.isEmpty) {
      return false;
    }
    await _saveGeofence(ids);
    return true;
  }

  Future<void> removeOldGeofence() async {
    var geofence = await GeofenceRepository().loadRegisteredGeofence();
    if (geofence == null) {
      return;
    }

    geofence.ids.forEach((id) async {
      debugPrint('remove geofence $id');
      await GeofencingManager.removeGeofenceById(id);
    });
    await GeofenceRepository().saveRegisteredGeofence(null);
  }

  Future<List<String>> _register() async {
    var draft = await DraftRepository().loadCurrentDraft();
    if (draft == null || draft.messageList.isEmpty) {
      return null;
    }
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
          draft.target.latitude,
          draft.target.longitude,
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
