import 'package:flutter/material.dart';

class SelectNotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('目的地の選択'),
        ),
        body: ListContainer());
    ;
  }
}

class ListContainer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ListContainerState();
}

class ListContainerState extends State<ListContainer> {
  var notificationList = [
    Notification(message: "test1", distance: 1000),
    Notification(message: "test2", distance: 2000),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notificationList.length,
      itemBuilder: (context, int index) {
        return Text(notificationList[index].message);
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
