import 'package:flutter/material.dart';
import 'package:omukae/pages/select_target_page.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Omukae'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              padding: EdgeInsets.all(20.0),
              color: Colors.lightBlue[100],
              onPressed: () {
                Navigator.push(context, new MaterialPageRoute(
                    builder: (BuildContext context) => new SelectTargetPage(),
                ));
              },
              child: Text('迎えに行く'),
            ),
          ],
        ),
      ),
    );
  }
}
