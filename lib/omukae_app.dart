import 'package:flutter/material.dart';
import 'package:geofencing/geofencing.dart';
import 'package:omukae/pages/welcome_page.dart';

class OmukaeApp extends StatefulWidget {
  @override
  _OmukaeAppState createState() => _OmukaeAppState();
}

class _OmukaeAppState extends State<OmukaeApp> {
  @override
  void initState() {
    super.initState();

    _initPlatformState();
  }

  Future<void> _initPlatformState() async {
    print('Initializing...');
    await GeofencingManager.initialize();
    print('Initialization done');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Omukae',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WelcomePage(),
    );
  }
}
