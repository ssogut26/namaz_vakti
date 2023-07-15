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
}
