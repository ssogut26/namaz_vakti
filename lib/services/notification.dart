import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class INotificationService {
  void initNotifications();
  void onDidReciveNotification(NotificationResponse notificationResponse);
  void showNotification(List<String>? prayerTimes);
  FlutterLocalNotificationsPlugin get _flutterLocalNotificationsPlugin;
}

class NotificationService implements INotificationService {
  NotificationService({this.ref});
  final WidgetRef? ref;
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
      'Fajr',
      'Sunrise',
      'Dhuhr',
      'Asr',
      'Maghrib',
      'Isha'
    ];

    final table = Table(
      children: const [
        TableRow(
          children: [
            Text('Fajr'),
            Text('Sunrise'),
            Text('Dhuhr'),
            Text('Asr'),
            Text('Maghrib'),
            Text('Isha'),
          ],
        ),
        TableRow(
          children: [
            Text('12:40'),
            Text('12:30'),
            Text('12:20'),
            Text('12,31'),
            Text('12:32'),
            Text('12:33'),
          ],
        ),
      ],
    );
    final androidNotificationDetails = AndroidNotificationDetails(
      'Prayer times app',
      'Prayer times app',
      channelDescription: 'Shows the prayer times in notification bar',
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      additionalFlags: Int32List.fromList(<int>[64, 2]),
      color: Colors.orange,
      colorized: true,
      showWhen: false,
      indeterminate: true,
      styleInformation: InboxStyleInformation([
        for (var i = 0; i < timeNames.length; i++)
          if (prayerTimes != null)
            if (prayerTimes[i] != '00:00') '${timeNames[i]}: ${prayerTimes[i]}'
      ]),
    );

    final notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await _flutterLocalNotificationsPlugin.show(
      0,
      '',
      '$prayerTimes',
      notificationDetails,
      payload: 'Test',
    );
  }
}

class MyBoxStyleInformation extends StyleInformation {
  /// Constructs an instance of [MyBoxStyleInformation].
  MyBoxStyleInformation(
    this.lines, {
    this.htmlFormatLines = false,
    this.contentTitle,
    this.htmlFormatContentTitle = false,
    this.summaryText,
    this.htmlFormatSummaryText = false,
  }) : super();

  /// Overrides ContentTitle in the big form of the template.
  final String? contentTitle;

  /// Set the first line of text after the detail section in the big form of
  /// the template.
  final String? summaryText;

  /// The lines that form part of the digest section for inbox-style
  /// notifications.
  final List<String> lines;

  /// Specifies if the lines should have formatting applied through HTML markup.
  final bool htmlFormatLines;

  /// Specifies if the overridden ContentTitle should have formatting applied
  /// through HTML markup.
  final bool? htmlFormatContentTitle;

  /// Specifies if formatting should be applied to the first line of text after
  /// the detail section in the big form of the template.
  final bool? htmlFormatSummaryText;
}
