import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DraftRepository {
  Future<void> saveCurrentDraft(Draft draft) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('draft', jsonEncode(draft.toJson()));
  }

  Future<Draft> loadCurrentDraft() async {
    var prefs = await SharedPreferences.getInstance();
    var draftString = await prefs.getString('draft');
    if (draftString == null) {
      return null;
    }
    return Draft.fromJson(jsonDecode(draftString));
  }
}

class Draft {
  double latitude;
  double longitude;
  List<Message> messageList;

  Draft({
    this.latitude,
    this.longitude,
    this.messageList,
  });

  Draft.fromJson(Map<String, dynamic> json)
      : latitude = json['latitude'],
        longitude = json['longitude'],
        messageList =
            (json['messageList'] as List)?.map((j) => Message.fromJson(j))?.toList();

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
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
