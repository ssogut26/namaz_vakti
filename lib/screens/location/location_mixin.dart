// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:namaz_vakti/screens/home/view/home_screen.dart';
import 'package:namaz_vakti/screens/location/location_selection.dart';
import 'package:namaz_vakti/screens/location/providers/location_providers.dart';
import 'package:permission_handler/permission_handler.dart';

mixin LocationMixin on ConsumerState<LocationSelectionScreen> {
  @override
  WidgetRef get ref;

  Future<void> openLocationBox() async {
    final locationBox = await Hive.openBox('locationBox');
  }

  @override
  void initState() {
    openLocationBox();
    super.initState();
  }

  void updateCountry(String? value) {
    final locationValues = ref.read(locationProvider.notifier);
    setState(() {
      locationValues.changeCountry(value);
      locationValues.changeCity('');
      locationValues.changeDistrict('');
    });
  }

  void updateCity(String? value) {
    final locationValues = ref.read(locationProvider.notifier);
    setState(() {
      locationValues.changeCity(value);
      locationValues.changeDistrict('');
    });
  }

  void updateDistrict(String? value) {
    final locationValues = ref.read(locationProvider.notifier);
    setState(() {
      locationValues.changeDistrict(value);
    });
  }

  void getPrayerTimesButton() {
    final locationValues = ref.read(locationProvider.notifier);
    (locationValues.state.district?.isEmpty ?? true)
        ? null
        : () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const HomeScreen(
                  isLocation: false,
                ),
              ),
            );
          };
  }

  Future<void> showLocationErrorDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Error'),
        content: const Text(
          'Please enable location services to continue',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> getPrayerTimesWithLocationFunction() async {
    final status = await Geolocator.requestPermission();
    print(status);
    switch (status) {
      case LocationPermission.denied:
        await showLocationErrorDialog();
      case LocationPermission.deniedForever:
        await openAppSettings();
      case LocationPermission.whileInUse:
        final location = await Geolocator.getCurrentPosition();
        ref.read(locatorProvider.notifier).position = location;
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => const HomeScreen(
              isLocation: true,
            ),
          ),
        );
      case LocationPermission.always:
        final location = await Geolocator.getCurrentPosition();
        ref.read(locatorProvider.notifier).position = location;
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => const HomeScreen(
              isLocation: true,
            ),
          ),
        );
      case LocationPermission.unableToDetermine:
        await showLocationErrorDialog();
    }
  }
}

mixin CountryMixin on ConsumerState<CountrySelectionWidget> {
  @override
  WidgetRef get ref;

  void updateCountry(String? value) {
    final locationValues = ref.read(locationProvider.notifier);
    final locationBox = Hive.box('locationBox');
    setState(() {
      locationValues.changeCountry(value);
      locationBox.put('country', value);
      locationValues.changeCity('');
      locationValues.changeDistrict('');
    });
  }
}

mixin CityMixin on ConsumerState<CitySelectionWidget> {
  @override
  WidgetRef get ref;

  void updateCity(String? value) {
    final locationValues = ref.read(locationProvider.notifier);
    final locationBox = Hive.box('locationBox');
    setState(() {
      locationValues.changeCity(value);
      locationBox.put('city', value);
      locationValues.changeDistrict('');
    });
  }
}

mixin DistrictMixin on ConsumerState<DistrictSelectionWidget> {
  @override
  WidgetRef get ref;

  void updateDistrict(String? value) {
    final locationValues = ref.read(locationProvider.notifier);
    final locationBox = Hive.box('locationBox');
    setState(() {
      locationValues.changeDistrict(value);
      locationBox.put('district', value);
    });
  }
}
