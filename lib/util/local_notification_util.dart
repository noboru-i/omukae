import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const String LOCAL_NOTIFICATION_CHANNEL_ID = "channel_local";

class LocalNotificationUtil {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  LocalNotificationUtil() {
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings(
//      onDidReceiveLocalNotification: onDidRecieveLocationLocation,
        );
    var initializationSettings = new InitializationSettings(
      initializationSettingsAndroid,
      initializationSettingsIOS,
    );
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
//      onSelectNotification: onSelectNotification,
    );
  }

  notify({
    String title,
    String body,
  }) {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      LOCAL_NOTIFICATION_CHANNEL_ID,
      '迎えに行く方の通知',
      '指定した距離に入ったタイミングで、通知したことをお知らせします。',
      importance: Importance.Default,
      priority: Priority.Default,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
      androidPlatformChannelSpecifics,
      iOSPlatformChannelSpecifics,
    );
    flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}
