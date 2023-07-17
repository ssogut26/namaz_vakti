// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namaz_vakti/extensions/extensions.dart';
import 'package:namaz_vakti/features/screens/home/view/home_screen.dart';
import 'package:namaz_vakti/features/screens/location/location_selection.dart';
import 'package:namaz_vakti/generated/locale_keys.g.dart';
import 'package:namaz_vakti/product/providers/location_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

mixin LocationRequirementsMixin on ConsumerState<LocationRequirements> {
  @override
  WidgetRef get ref;
  SharedPreferences? prefs;
  late final LocationNotifier locationValues;

  @override
  void initState() {
    locationValues = ref.read(locationProvider.notifier);
    super.initState();
  }

  void updateCountry(String? value) {
    setState(() {
      locationValues.changeCountry(value);
    });
  }

  void updateCity(String? value) {
    print(value);

    setState(() {
      locationValues.changeCity(
        value,
      );
    });
  }

  void updateDistrict(String? value) {
    print(value);

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
    print(locationValues.state.district);
    locationValues.state.district == null || locationValues.state.district == ''
        ? await showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(LocaleKeys.locationSelection_error.locale),
              content: Text(LocaleKeys.locationSelection_tryAgain.locale),
            ),
          )
        : await Navigator.of(context)
            .push(
            MaterialPageRoute<void>(
              builder: (context) => const HomeScreen(),
            ),
          )
            .whenComplete(() async {
            await locationValues.changeCountry('');
            await locationValues.changeCity('');
            await locationValues.changeDistrict('');
          });
  }
}
