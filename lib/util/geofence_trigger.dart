import 'dart:math';

import 'package:geofencing/geofencing.dart';
import 'package:omukae/repository/draft_repository.dart';
import 'package:omukae/util/local_notification_util.dart';

abstract class GeofenceTrigger {
  static Future<void> callback(
      List<String> ids, Location l, GeofenceEvent e) async {
    print('callback Fences: $ids Location $l Event: $e');
    var maxId = ids.map((s) => int.parse(s)).reduce(max);

    var repository = DraftRepository();
    var draft = await repository.loadCurrentDraft();
    var message = draft.messageList[maxId];

    var notificationUtil = LocalNotificationUtil();
    notificationUtil.notify(title: 'omukae', body: 'message: ' + message.text);
  }
}
