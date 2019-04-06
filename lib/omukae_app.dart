import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:geofencing/geofencing.dart';
import 'package:omukae/pages/welcome_page.dart';

class OmukaeApp extends StatefulWidget {
  @override
  _OmukaeAppState createState() => _OmukaeAppState();
}

class _OmukaeAppState extends State<OmukaeApp> {
  static FirebaseAnalytics analytics = FirebaseAnalytics();

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
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
      home: WelcomePage(),
    );
  }
}
