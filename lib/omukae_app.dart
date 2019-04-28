import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geofencing/geofencing.dart';
import 'package:omukae/pages/welcome_page.dart';
import 'package:omukae/util/local_notification_util.dart';

class OmukaeApp extends StatefulWidget {
  @override
  _OmukaeAppState createState() => _OmukaeAppState();
}

class _OmukaeAppState extends State<OmukaeApp> {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();

    _initPlatformState();
    _initFirebaseMessaging();
  }

  Future<void> _initPlatformState() async {
    print('Initializing...');
    await GeofencingManager.initialize();
    print('Initialization done');
  }

  _initFirebaseMessaging() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        var notificationUtil = LocalNotificationUtil();
        notificationUtil.notify(
            title: 'omukae', body: 'message from local: ' + message['notification']['body']);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(sound: true, badge: true, alert: true),
    );
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      print("firebase token: " + token);
    });
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
