import 'package:flutter/material.dart';

class SelectNotificationPage extends StatefulWidget {
  @override
  _SelectNotificationPageState createState() => _SelectNotificationPageState();
}

class _SelectNotificationPageState extends State<SelectNotificationPage> {
  final _key = GlobalKey<ListContainerState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('通知の設定'),
      ),
      body: ListContainer(
        key: _key,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          var newNotification = await _showInputDialog(context: context);
          if (newNotification != null) {
            _key.currentState.add(newNotification);
          }
        },
      ),
    );
  }
}

Future<Notification> _showInputDialog({
  @required BuildContext context,
  Notification initNotification,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return _InputDialog(initNotification: initNotification);
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
  List<Notification> _notificationList = [];

  add(Notification notification) {
    setState(() {
      _notificationList.add(notification);
      _notificationList.sort((a, b) => b.distance.compareTo(a.distance));
    });
  }

  edit(Notification notification, int index) {
    setState(() {
      _notificationList[index] = notification;
      _notificationList.sort((a, b) => b.distance.compareTo(a.distance));
    });
  }

  @override
  Widget build(BuildContext context) {
    return _notificationList.isEmpty
        ? Center(child: Text('右下のボタンから、通知を作成してください。'))
        : ListView.builder(
            itemCount: _notificationList.length,
            itemBuilder: (context, int index) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _notificationList[index].message,
                        style: Theme.of(context).textTheme.subtitle,
                      ),
                    ),
                    Text(
                      (_notificationList[index].distance / 1000.0)
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
                        var editedNotification = await _showInputDialog(
                          context: context,
                          initNotification: _notificationList[index],
                        );
                        edit(editedNotification, index);
                      },
                    ),
                  ],
                ),
              );
            },
          );
  }
}

class Notification {
  const Notification({
    @required this.message,
    this.distance = 0,
  });

  final String message;

  // unit is meter.
  final int distance;
}

class _InputDialog extends StatefulWidget {
  final Notification initNotification;

  const _InputDialog({
    this.initNotification,
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
      var result = Notification(message: _message, distance: _distance);
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
              initialValue: widget.initNotification?.message,
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
              initialValue: widget.initNotification?.distance?.toString(),
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
