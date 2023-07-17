import 'package:flutter/material.dart';
import 'package:namaz_vakti/extensions/extensions.dart';
import 'package:namaz_vakti/generated/locale_keys.g.dart';

final class AppConstants {
  static const String baseURL = 'https://namaz-vakti.vercel.app/api/';
  static const List<String> timeIcons = [
    'assets/svg/fajr.svg',
    'assets/svg/sunrise.svg',
    'assets/svg/dhuhr.svg',
    'assets/svg/asr.svg',
    'assets/svg/maghrib.svg',
    'assets/svg/isha.svg',
  ];
  final timeNames = <String>[
    LocaleKeys.prayerTimes_fajr.locale,
    LocaleKeys.prayerTimes_sunrise.locale,
    LocaleKeys.prayerTimes_dhuhr.locale,
    LocaleKeys.prayerTimes_asr.locale,
    LocaleKeys.prayerTimes_maghrib.locale,
    LocaleKeys.prayerTimes_isha.locale,
  ];

  static const needle = 'assets/svg/needle.svg';
  static const compass = 'assets/svg/compass.svg';

  static const lemonJuice = Color(0xFFF9F5E3);
  static const pistachio = Color(0XFFC3D350);
  static const midnightBlue = Color(0xFF7A918D);
  static const phosphoreGreen = Color(0XFFC2F9BB);
  static const skyBlue = Color(0xFF8ACDEA);
  static const sweetOrange = Color(0xFFF38D68);
  static const beachBlue = Color(0xff88D9E6);
  static const stoneDark = Color(0xff374B4A);
}
