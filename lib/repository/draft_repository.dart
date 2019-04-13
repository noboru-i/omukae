import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:omukae/data/gps_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DraftRepository {
  Future<void> saveCurrentDraft(Draft draft) async {
    var prefs = await SharedPreferences.getInstance();

    _updateUuidIfNeeded(draft);
    await prefs.setString('draft', jsonEncode(draft.toJson()));
  }

  Future<Draft> loadCurrentDraft() async {
    var prefs = await SharedPreferences.getInstance();
    var draftString = prefs.getString('draft');
    if (draftString == null) {
      return null;
    }
    return Draft.fromJson(jsonDecode(draftString));
  }

  _updateUuidIfNeeded(Draft draft) {
    if (draft.notifyUuid == null || draft.notifyUuid.isNotEmpty) {
      return;
    }

    draft.notifyUuid = Uuid().v4();
  }
}

class Draft {
  GpsData target;
  double initialDistance;
  String notifyUuid;
  List<Message> messageList;

  Draft({
    this.target,
    this.initialDistance,
    this.notifyUuid,
    this.messageList,
  });

  Draft.fromJson(Map<String, dynamic> json)
      : target = GpsData.fromJson(json['target']),
        initialDistance = json['initialDistance'],
        notifyUuid = json['uuid'],
        messageList = (json['messageList'] as List)
            ?.map((j) => Message.fromJson(j))
            ?.toList();

  Map<String, dynamic> toJson() => {
        'target': target.toJson(),
        'initialDistance': initialDistance,
        'notifyUuid': notifyUuid,
        'messageList': messageList?.map((m) => m.toJson())?.toList()
      };
}

class Message {
  final String text;

  // unit is meter.
  final int distance;

  const Message({
    @required this.text,
    this.distance = 0,
  });

  Message.fromJson(Map<String, dynamic> json)
      : text = json['text'],
        distance = json['distance'];

  Map<String, dynamic> toJson() => {
        'text': text,
        'distance': distance,
      };
}
