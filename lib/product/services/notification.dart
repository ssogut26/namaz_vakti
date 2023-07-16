import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:namaz_vakti/constants/constants.dart';
import 'package:namaz_vakti/extensions/extensions.dart';
import 'package:namaz_vakti/generated/locale_keys.g.dart';

abstract class INotificationService {
  void initNotifications();
  void onDidReciveNotification(NotificationResponse notificationResponse);
  void showNotification(List<String> prayerTimes);
  FlutterLocalNotificationsPlugin get _flutterLocalNotificationsPlugin;
}

class NotificationService implements INotificationService {
  NotificationService();

  @override
  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  @override
  Future<void> initNotifications() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();

// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const initializationSettingsAndroid =
        AndroidInitializationSettings('drawable/ic_stat_mosque');
    final initializationSettingsDarwin = DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        // your call back to the UI
      },
    );
    const initializationSettingsLinux = LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );
    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
    );
    await _flutterLocalNotificationsPlugin
        .initialize(
          initializationSettings,
          onDidReceiveNotificationResponse: onDidReciveNotification,
        )
        .whenComplete(() => debugPrint('Notification initialized'));
  }

  @override
  Future<void> onDidReciveNotification(
    NotificationResponse notificationResponse,
  ) async {
    final payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('notification payload: $payload');
    }
  }

  @override
  Future<void> showNotification(List<String> prayerTimes) async {
    final androidNotificationDetails = AndroidNotificationDetails(
      LocaleKeys.appName.locale,
      LocaleKeys.appChannel.locale,
      channelDescription: LocaleKeys.appDescription.locale,
      priority: Priority.low,
      autoCancel: false,
      color: Colors.orange,
      colorized: true,
      ongoing: true,
      enableVibration: false,
      playSound: false,
      showWhen: false,
      styleInformation: InboxStyleInformation(
        [
          for (var i = 0; i < prayerTimes.length; i++)
            for (var j = 0; j < AppConstants().timeNames.length; j++)
              if (i == j) '${AppConstants().timeNames[j]}: ${prayerTimes[i]}'
        ],
      ),
    );
    final notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await _flutterLocalNotificationsPlugin.show(
      0,
      LocaleKeys.appName.locale,
      prayerTimes.map((e) => e).join('\n'),
      notificationDetails,
    );
  }
}
