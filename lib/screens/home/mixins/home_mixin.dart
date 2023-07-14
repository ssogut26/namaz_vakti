import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:namaz_vakti/models/prayer_times.dart';
import 'package:namaz_vakti/screens/home/view/home_screen.dart';
import 'package:namaz_vakti/services/notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

mixin HomeScreenMixin on ConsumerState<HomeScreen> {
  @override
  WidgetRef get ref;
  bool? isLocation;

  /// It was'nt work with the hive so I used shared preferences in here.
  Future<void> getLocationBoolValue() async {
    final prefs = await SharedPreferences.getInstance();
    isLocation = prefs.getBool('isLocationEnabled');
  }

  final GlobalKey<ScaffoldState> key = GlobalKey();
  final cacheHive = Hive.box<PrayerTimesModel>('prayerTimesModel');

  Future<void> showNotification(List<String> prayerTimes) async {
    await NotificationService().initNotifications();
    await NotificationService().showNotification(prayerTimes);
  }

  bool isLoading = true;
  @override
  void initState() {
    getLocationBoolValue();
    final prayerTimes = ref.read(prayerTimesProvider.notifier).prayerTimes;

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => showNotification(
        prayerTimes?.first ??
            cacheHive.get('prayerTimes')?.times?.values.first ??
            [],
      ),
    );

    super.initState();
  }
}
