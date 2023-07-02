// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namaz_vakti/screens/home/view/home_screen.dart';
import 'package:namaz_vakti/screens/location/location_selection.dart';
import 'package:namaz_vakti/screens/location/providers/location_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

mixin LocationRequirementsMixin on ConsumerState<LocationRequirements> {
  @override
  WidgetRef get ref;
  late final SharedPreferences prefs;

  late final LocationNotifier locationValues =
      ref.read(locationProvider.notifier);

  Future<void> updateCountry(String? value) async {
    await prefs.setString('country', value ?? '');
    setState(() {
      locationValues.changeCountry(value);
    });
  }

  Future<void> updateCity(String? value) async {
    await prefs.setString('city', value ?? '');
    setState(() {
      locationValues.changeCity(
        value,
      );
    });
  }

  Future<void> updateDistrict(String? value) async {
    await prefs.setString('district', value ?? '');
    setState(() {
      locationValues.changeDistrict(value);
    });
  }
}

mixin LocationMixin on ConsumerState<LocationSelectionScreen> {
  @override
  WidgetRef get ref;
  late final LocationNotifier locationValues =
      ref.read(locationProvider.notifier);

  Future<void> getPrayerTimesButton() async {
    locationValues.state.district == null || locationValues.state.district == ''
        ? await showDialog<void>(
            context: context,
            builder: (context) => const AlertDialog(
              title: Text('Error'),
              content: Text('Try again with a valid location.'),
            ),
          )
        : await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => const HomeScreen(
                isLocation: false,
              ),
            ),
          );
  }
}
