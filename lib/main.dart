import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:namaz_vakti/app.dart';
import 'package:namaz_vakti/models/prayer_times.dart';
import 'package:namaz_vakti/services/notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(PrayerTimesModelAdapter());
  await NotificationService().initNotifications();

  Hive.registerAdapter(PlaceAdapter());
  await Hive.openBox<PrayerTimesModel>('prayerTimesModel');
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      child: NamazVaktiApp(prefs: prefs),
    ),
  );
}
