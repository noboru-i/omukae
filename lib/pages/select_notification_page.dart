import 'package:flutter/material.dart';
import 'package:omukae/pages/confirm_page.dart';
import 'package:omukae/repository/draft_repository.dart';
import 'package:omukae/ui/distance_label.dart';
import 'package:omukae/ui/input_message_dialog.dart';
import 'package:omukae/util/geofencing_util.dart';
import 'package:omukae/util/local_notification_util.dart';

class SelectNotificationPage extends StatelessWidget {
  final _listStateKey = GlobalKey<ListContainerState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('通知の設定'),
      ),
      body: SafeArea(
        child: _SelectNotificationInternal(
          listStateKey: _listStateKey,
        ),
      ),
      floatingActionButton: Container(
        padding: EdgeInsets.only(bottom: 100.0),
        child: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {
            var newMessage = await showInputDialog(context: context);
            if (newMessage != null) {
              _listStateKey.currentState._add(newMessage);
            }
          },
        ),
      ),
    );
  }
}

class _SelectNotificationInternal extends StatefulWidget {
  const _SelectNotificationInternal({
    Key key,
    this.listStateKey,
  }) : super(key: key);

  final GlobalKey<ListContainerState> listStateKey;

  @override
  _SelectNotificationInternalState createState() =>
      _SelectNotificationInternalState();
}

class _SelectNotificationInternalState
    extends State<_SelectNotificationInternal> {
  Draft draft;

  _moveToNext() async {
    // initialize for request permission
    LocalNotificationUtil();

    var repository = DraftRepository();
    var draft = await repository.loadCurrentDraft();
    draft.messageList = widget.listStateKey.currentState.messageList;
    await repository.saveCurrentDraft(draft);

    var result = await GeofencingUtil().registerGeofencing();

    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            content: Text(
              result ? '通知設定が完了しました。' : '通知設定に失敗しました。',
            ),
            actions: <Widget>[
              FlatButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.pop(context);
                  })
            ],
          ),
    );

    if (result) {
      Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (BuildContext context) => new ConfirmPage(),
        ),
      );
    }
  }

  _loadDraft() async {
    var draft = await DraftRepository().loadCurrentDraft();
    setState(() {
      this.draft = draft;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        draft == null
            ? Container()
            : Container(
                padding: EdgeInsets.only(
                    top: 12.0, right: 8.0, bottom: 12.0, left: 8.0),
                child: DistanceLabel(
                  // TODO use initialDistance.
                  targetPosition: draft.target,
                ),
              ),
        Expanded(
          child: ListContainer(
            key: widget.listStateKey,
          ),
        ),
        RaisedButton(
          padding: EdgeInsets.all(20.0),
          onPressed: _moveToNext,
          color: Colors.blue[800],
          child: const Text(
            '通知を設定する',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class ListContainer extends StatefulWidget {
  const ListContainer({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ListContainerState();
}

class ListContainerState extends State<ListContainer> {
//  List<Message> messageList = [];
  List<Message> messageList = [
    Message(text: '5キロ', distance: 5000),
    Message(text: '4キロ', distance: 4000),
    Message(text: '3キロ', distance: 3000),
    Message(text: '2キロ', distance: 2000),
    Message(text: '1キロ', distance: 1000),
    Message(text: '0.5キロ', distance: 500),
  ];

  _add(Message message) {
    setState(() {
      messageList.add(message);
      _sort();
    });
  }

  _edit(Message message, int index) {
    setState(() {
      messageList[index] = message;
      _sort();
    });
  }

  _remove(int index) {
    setState(() {
      messageList.removeAt(index);
      _sort();
    });
  }

  _sort() {
    messageList.sort((a, b) => b.distance.compareTo(a.distance));
  }

  @override
  Widget build(BuildContext context) {
    return messageList.isEmpty
        ? Center(child: Text('右下のボタンから、通知を作成してください。'))
        : ListView.builder(
            itemCount: messageList.length,
            itemBuilder: (context, int index) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        messageList[index].text,
                        style: Theme.of(context).textTheme.subtitle,
                      ),
                    ),
                    Text(
                      (messageList[index].distance / 1000.0)
                              .toStringAsFixed(2) +
                          "km",
                      style: Theme.of(context).textTheme.caption,
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () async {
                        var editedMessage = await showInputDialog(
                          context: context,
                          initMessage: messageList[index],
                        );
                        if (editedMessage != null) {
                          _edit(editedMessage, index);
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _remove(index);
                      },
                    ),
                  ],
                ),
              );
            },
          );
  }
}
