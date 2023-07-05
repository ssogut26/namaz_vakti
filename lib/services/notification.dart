import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

abstract class INotificationService {
  void initNotifications();
  void onDidReciveNotification(NotificationResponse notificationResponse);
  void showNotification(List<String>? prayerTimes);
  FlutterLocalNotificationsPlugin get _flutterLocalNotificationsPlugin;
}

class NotificationService implements INotificationService {
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
        AndroidInitializationSettings('mipmap/ic_launcher');
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
  Future<void> showNotification(List<String>? prayerTimes) async {
    final timeNames = <String>[
      'İmsak',
      'Güneş',
      'Öğle',
      'İkindi',
      'Akşam',
      'Yatsı'
    ];
    final androidNotificationDetails = AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      channelShowBadge: false,
      playSound: false,
      color: Colors.red,
      colorized: true,
      styleInformation: BigTextStyleInformation(
        summaryText: 'summaryText',
        contentTitle: '${timeNames.followedBy(prayerTimes ?? <String>[])}',
        '',
      ),
    );
    final notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await _flutterLocalNotificationsPlugin.show(
      0,
      '$prayerTimes',
      '$prayerTimes',
      notificationDetails,
      payload: 'Test',
    );
  }
}

class MyCustomStyleInformation extends DefaultStyleInformation {
  MyCustomStyleInformation({
    this.summaryText,
    this.contentTitle,
    bool htmlFormatContent = false,
    bool htmlFormatTitle = false,
  }) : super(htmlFormatContent, htmlFormatTitle);

  final List<String>? summaryText;
  final List<String>? contentTitle;

  bool? htmlFormatContentTitle;

  /// Specifies if formatting should be applied to the first line of text after
  /// the detail section in the big form of the template.
  bool? htmlFormatSummaryText;
}
