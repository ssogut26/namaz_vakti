// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:namaz_vakti/features/models/location_model.dart';
import 'package:namaz_vakti/features/screens/home/view/home_screen.dart';
import 'package:namaz_vakti/product/services/api.dart';
import 'package:namaz_vakti/product/services/api_provider.dart';
import 'package:namaz_vakti/product/services/connection_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// This is the state of the location notifier. It will be used to store the
/// location values like country, city and district. You can set it with
/// [copyWith] method.
class LocationNotifier extends StateNotifier<LocationModel> {
  LocationNotifier(this.locationModel) : super(const LocationModel());
  final LocationModel locationModel;

  Future<void> changeCountry(String? value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('country');
    await prefs.setString('country', value ?? '');
    state = state.copyWith(country: value, city: '', district: '');
  }

  Future<void> changeCity(String? value) async {
    final prefs = await SharedPreferences.getInstance();
    print(prefs.getString('city'));
    await prefs.remove('city');
    await prefs.setString('city', value ?? '');
    print(prefs.getString('city'));
    state = state.copyWith(city: value ?? '', district: '');
  }

  Future<void> changeDistrict(String? value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('district');
    await prefs.setString('district', value ?? '');
    state = state.copyWith(district: value ?? '');
  }
}

/// This is the provider that will be used to read the location state.
final locationProvider = StateNotifierProvider(
  (ref) => LocationNotifier(
    const LocationModel(),
  ),
);

/// This provider using for the pullign the countries from the API.
final countrySelectionProvider = FutureProvider.autoDispose(
  (ref) async {
    final apiService = ref.read(apiProvider);
    final countries = await apiService.getCountries();
    return countries;
  },
);

/// This provider using for the pullign the city from the API. For
/// working properly, you need to pass the country name as a parameter.
final citySelectionProvider =
    FutureProvider.family.autoDispose((ref, String? country) async {
  final apiService = ref.read(apiProvider);

  final cities = await apiService.getCities(country ?? '');
  return cities;
});

/// This provider using for the pullign the district from the API. For
/// working properly, you need to pass the country name and city name as a
/// parameter.
final districtSelectionProvider =
    FutureProvider.family.autoDispose((ref, LocationModel location) async {
  final districts = await ApiService.instance
      .getDistrict(location.country ?? '', location.city ?? '');
  return districts;
});

/// This provider using for the pullign the prayer times from the API. For
/// working properly, you need to pass the country name, city name,
/// district name, and date as a parameter.

final getPrayerTimesWithSelection =
    FutureProvider.family.autoDispose((ref, String dates) async {
  // final locationBox = Hive.box<LocationModel>('locationBox');
  final country = ref.watch(locationProvider.notifier).state.country;
  final city = ref.watch(locationProvider.notifier).state.city;
  final district = ref.watch(locationProvider.notifier).state.district;
  final connection = ref.watch(connectivityProvider);
  if (country == '' || city == '' || district == '') {
    return null;
  } else {
    final apiService = ref.read(apiProvider);
    final prefs = await SharedPreferences.getInstance();
    final co = prefs.getString('country');
    final ci = prefs.getString('city');
    final di = prefs.getString('district');
    print(
      'country: $co, city: $ci, district: $di, c = $country, c = $city, c = $district',
    );
    if (connection == ConnectivityStatus.isConnected) {
      final prayerTimes = await apiService.getPrayerTimes(
        co ?? country ?? '',
        ci ?? city ?? '',
        di ?? district ?? '',
        dates,
      );
      return prayerTimes;
    } else {
      return null;
    }
  }
});

/// This provider using for the pullign the prayer times from the API. For
/// working properly, user must grant the location permission and enable it.
/// If the user doesn't grant the permission, it will return null.
final getPrayerTimesWithLocation =
    FutureProvider.family.autoDispose((ref, String dates) async {
  final locator = ref.watch(locatorProvider.notifier).position;
  final apiService = ref.read(apiProvider);
  final prefs = await SharedPreferences.getInstance();
  final lat = prefs.getString('latitude');
  final lon = prefs.getString('longitude');
  print('latitude: $lat, longitude: $lon');
  final prayerTimes = await apiService.getPrayerTimesByLocation(
    latitude: lat ?? locator?.latitude.toString() ?? '',
    longitude: lon ?? locator?.longitude.toString() ?? '',
    date: dates,
  );
  return prayerTimes;
});

/// This using for the setting position values and boolean value for the
/// location permission.
class LocatorNotifier extends StateNotifier<bool> {
  LocatorNotifier({this.isLocationEnabled = false}) : super(false);

  bool? isLocationEnabled;
  Future<bool> changeLocationStatus({bool? value = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLocationEnabled', value ?? false);

    return isLocationEnabled = value ?? false;
  }

  Position? position;
  Future<Position> updatePosition(Position value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('latitude', value.latitude.toString());
    await prefs.setString('longitude', value.longitude.toString());
    return position = value;
  }
}

/// This provider using for the read the location permission status and
/// position values.
final locatorProvider = StateNotifierProvider(
  (ref) => LocatorNotifier(),
);
