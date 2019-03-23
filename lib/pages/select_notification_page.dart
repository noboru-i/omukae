import 'package:flutter/material.dart';
import 'package:omukae/pages/confirm_page.dart';
import 'package:omukae/repository/draft_repository.dart';

class SelectNotificationPage extends StatefulWidget {
  @override
  _SelectNotificationPageState createState() => _SelectNotificationPageState();
}

class _SelectNotificationPageState extends State<SelectNotificationPage> {
  final _key = GlobalKey<ListContainerState>();

  _moveToNext() async {
    var repository = DraftRepository();
    var draft = await repository.loadCurrentDraft();
    draft.messageList = _key.currentState.messageList;
    await repository.saveCurrentDraft(draft);
    Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (BuildContext context) => new ConfirmPage(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('通知の設定'),
        actions: [
          FlatButton(
            child: const Text(
              "完了",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: _moveToNext,
          ),
        ],
      ),
      body: ListContainer(
        key: _key,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          var newMessage = await _showInputDialog(context: context);
          if (newMessage != null) {
            _key.currentState.add(newMessage);
          }
        },
      ),
    );
  }
}

Future<Message> _showInputDialog({
  @required BuildContext context,
  Message initMessage,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return _InputDialog(initMessage: initMessage);
    },
  );
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
    Message(text: '3キロ', distance: 3000),
    Message(text: '2キロ', distance: 2000),
    Message(text: '1キロ', distance: 1000),
    Message(text: '0.5キロ', distance: 500),
  ];

  add(Message message) {
    setState(() {
      messageList.add(message);
      messageList.sort((a, b) => b.distance.compareTo(a.distance));
    });
  }

  edit(Message message, int index) {
    setState(() {
      messageList[index] = message;
      messageList.sort((a, b) => b.distance.compareTo(a.distance));
    });
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
                        var editedMessage = await _showInputDialog(
                          context: context,
                          initMessage: messageList[index],
                        );
                        edit(editedMessage, index);
                      },
                    ),
                  ],
                ),
              );
            },
          );
  }
}

class _InputDialog extends StatefulWidget {
  final Message initMessage;

  const _InputDialog({
    this.initMessage,
  });

  @override
  State<StatefulWidget> createState() => _InputDialogState();
}

class _InputDialogState extends State<_InputDialog> {
  final _formKey = new GlobalKey<FormState>();
  String _message;
  int _distance;

  _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      var result = Message(text: _message, distance: _distance);
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: widget.initMessage?.text,
              autofocus: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Message',
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter message.';
                }
              },
              onSaved: (String value) {
                this._message = value;
              },
            ),
            SizedBox(height: 8.0),
            TextFormField(
              initialValue: widget.initMessage?.distance?.toString(),
              autofocus: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Distance [meter]',
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter distance.';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter distance as integer.';
                }
              },
              onSaved: (String value) {
                this._distance = int.parse(value);
              },
            ),
          ],
        ),
      ),
      actions: [
        FlatButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.pop(context, null);
          },
        ),
        FlatButton(child: const Text('OK'), onPressed: this._submit),
      ],
    );
  }
}
