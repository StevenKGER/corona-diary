import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin _notifications =
    FlutterLocalNotificationsPlugin();
bool _initiated = false;

void initNotifications() {
  if (_initiated) return;

  _notifications.initialize(
      InitializationSettings(android: AndroidInitializationSettings("corona")));
  _initiated = true;
}

void showNotification(String title, String description) {
  _notifications.show(
      0,
      title,
      description,
      NotificationDetails(
          android: AndroidNotificationDetails(
              "corona_diary_0", title, description)));
}
