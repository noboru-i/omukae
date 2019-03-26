import 'package:flutter/material.dart';
import 'package:omukae/repository/draft_repository.dart';

Future<Message> showInputDialog({
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
