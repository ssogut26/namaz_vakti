// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:namaz_vakti/screens/location/location_model.dart';
import 'package:namaz_vakti/services/api.dart';
import 'package:namaz_vakti/services/api_provider.dart';

class LocationNotifier extends StateNotifier<LocationModel> {
  LocationNotifier(this.locationModel) : super(const LocationModel());
  final LocationModel locationModel;

  void changeCountry(String? value) {
    state = state.copyWith(country: value, city: '', district: '');
  }

  void changeCity(String? value) {
    state = state.copyWith(city: value ?? '', district: '');
  }

  void changeDistrict(String? value) {
    state = state.copyWith(district: value ?? '');
  }
}

final locationProvider = StateNotifierProvider(
  (ref) => LocationNotifier(
    const LocationModel(),
  ),
);

final countrySelectionProvider = FutureProvider(
  (ref) async {
    final apiService = ref.read(apiProvider);
    final countries = await apiService.getCountries();
    return countries;
  },
);

final citySelectionProvider =
    FutureProvider.family((ref, String? country) async {
  final apiService = ref.read(apiProvider);

  final cities = await apiService.getCities(country ?? '');
  return cities;
});

final districtSelectionProvider =
    FutureProvider.family.autoDispose((ref, LocationModel location) async {
  final districts = await ApiService.instance
      .getDistrict(location.country ?? '', location.city ?? '');

  return districts;
});

final getPrayerTimesWithSelection =
    FutureProvider.family.autoDispose((ref, String dates) async {
  final locationBox = Hive.box('locationBox');
  final country = ref.watch(locationProvider.notifier).state.country;
  final city = ref.watch(locationProvider.notifier).state.city;
  final district = ref.watch(locationProvider.notifier).state.district;
  if (country == '' || city == '' || district == '') {
    return null;
  } else {
    final apiService = ref.read(apiProvider);

    final prayerTimes = await apiService.getPrayerTimes(
      locationBox.get('country') as String? ?? country ?? '',
      locationBox.get('city') as String? ?? city ?? '',
      locationBox.get('district') as String? ?? district ?? '',
      dates,
    );
    return prayerTimes;
  }
});

final getPrayerTimesWithLocation =
    FutureProvider.family.autoDispose((ref, String dates) async {
  final locator = ref.watch(locatorProvider.notifier).position;
  final apiService = ref.read(apiProvider);

  final prayerTimes = await apiService.getPrayerTimesByLocation(
    latitude: locator?.latitude.toString() ?? '',
    longitude: locator?.longitude.toString() ?? '',
    date: dates,
  );
  return prayerTimes;
});

class LocatorNotifier extends StateNotifier<bool> {
  LocatorNotifier({this.isLocationEnabled = false}) : super(false);

  bool isLocationEnabled = false;
  bool changeLocationStatus({bool value = false}) {
    return isLocationEnabled = value;
  }

  final locationBox = Hive.box('locationBox');

  Position? position;
  Position updatePosition(Position value) {
    final pos = locationBox.get('position') as Position?;
    if (pos == null) {
      locationBox.put('position', value);
      return position = value;
    } else {
      return position = pos;
    }
  }
}

final locatorProvider = StateNotifierProvider(
  (ref) => LocatorNotifier(),
);
