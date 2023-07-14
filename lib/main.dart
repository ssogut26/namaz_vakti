import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:namaz_vakti/app.dart';
import 'package:namaz_vakti/models/prayer_times.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(PrayerTimesModelAdapter());
  final prefs = await SharedPreferences.getInstance();
  Hive.registerAdapter(PlaceAdapter());
  await Hive.openBox<PrayerTimesModel>('prayerTimesModel');
  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('tr', 'TR'),
        ],

        fallbackLocale: const Locale('en', 'US'),
        path: 'assets/lang', // <-- change the path of the translation files
        child: NamazVaktiApp(prefs: prefs),
      ),
    ),
  );
}
