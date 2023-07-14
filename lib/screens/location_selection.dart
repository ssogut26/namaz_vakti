// ignore_for_file: prefer_if_elements_to_conditional_expressions

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:namaz_vakti/models/countries.dart';
import 'package:namaz_vakti/screens/home/view/home_screen.dart';
import 'package:namaz_vakti/services/api.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationNotifier extends ChangeNotifier {
  String? _country;
  String? get country => _country;
  set country(String? value) {
    _country = value;
    notifyListeners();
  }

  String? _city;

  String? get city => _city;

  set city(String? value) {
    _city = value;
    notifyListeners();
  }

  String? _district;

  String? get district => _district;

  set district(String? value) {
    _district = value;
    notifyListeners();
  }
}

final locationProvider = ChangeNotifierProvider((ref) => LocationNotifier());

final countrySelectionProvider = FutureProvider(
  (ref) async {
    final countries = await ApiService.instance.getCountries();

    return countries;
  },
);

final citySelectionProvider = FutureProvider((ref) async {
  final country = ref.watch(locationProvider).country;
  final cities = await ApiService.instance.getCities(country ?? '');
  return cities;
});

final districtSelectionProvider = FutureProvider((ref) async {
  final country = ref.watch(locationProvider).country;
  final city = ref.watch(locationProvider).city;
  final districts =
      await ApiService.instance.getDistrict(country ?? '', city ?? '');

  return districts;
});

final getPrayerTimesWithSelection =
    FutureProvider.family.autoDispose((ref, String dates) async {
  final country = ref.watch(locationProvider).country;
  final city = ref.watch(locationProvider).city;
  final district = ref.watch(locationProvider).district;
  if (country != null && city != null && district != null) {
    final prayerTimes = await ApiService.instance.getPrayerTimes(
      country,
      city,
      district,
      dates,
    );

    return prayerTimes;
  } else if (country == '' && city == '' && district == '') {
    return null;
  } else {
    return null;
  }
});

final getPrayerTimesWithLocation =
    FutureProvider.family.autoDispose((ref, String dates) async {
  final locator = ref.watch(locatorProvider);
  final prayerTimes = await ApiService.instance.getPrayerTimesByLocation(
    latitude: locator.position?.latitude.toString() ?? '',
    longitude: locator.position?.longitude.toString() ?? '',
    date: dates,
  );
  return prayerTimes;
});

class LocatorNotifier extends ChangeNotifier {
  bool _isLocationEnabled = false;
  bool get isLocationEnabled => _isLocationEnabled;
  set isLocationEnabled(bool value) {
    _isLocationEnabled = value;
    notifyListeners();
  }

  Position? _position;
  Position? get position => _position;
  set position(Position? value) {
    _position = value;
    notifyListeners();
  }
}

final locatorProvider = ChangeNotifierProvider((ref) => LocatorNotifier());

class LocationSelectionScreen extends ConsumerStatefulWidget {
  const LocationSelectionScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      LocationSelectionScreenState();
}

class LocationSelectionScreenState
    extends ConsumerState<LocationSelectionScreen> {
  String? selectedCountry;
  String? selectedCity;
  String? selectedDistrict;

  @override
  Widget build(BuildContext context) {
    final countrySelection = ref.watch(countrySelectionProvider);

    final location = ref.watch(locationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Selection'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  DropdownSearch<String?>(
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: 'Country',
                        hintText: 'Select country',
                      ),
                    ),
                    selectedItem: selectedCountry,
                    popupProps: const PopupProps.modalBottomSheet(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          labelText: 'Ülke',
                          hintText: 'Ülke seçiniz',
                        ),
                      ),
                      searchDelay: Duration(milliseconds: 300),
                      isFilterOnline: true,
                    ),
                    asyncItems: (String filter) async {
                      return countrySelection.when(
                        data: (List<CountriesModel?> countryList) {
                          final filteredCountries = countryList
                              .where(
                                (country) =>
                                    country?.name
                                        ?.toLowerCase()
                                        .startsWith(filter) ??
                                    false,
                              )
                              .toList();
                          final countryNameList = <String>[];
                          for (final country in filteredCountries) {
                            countryNameList.add(country!.name!);
                          }
                          return countryNameList;
                        },
                        loading: () => [
                          'Loading',
                        ],
                        error: (error, stackTrace) => [
                          'Error',
                        ],
                      );
                    },
                    onChanged: (value) {
                      ref.watch(locationProvider).country = value;
                      ref.watch(locationProvider).city = null;
                      ref.watch(locationProvider).district = null;
                    },
                  ),
                  (location._country == null || location._country == '')
                      ? const SizedBox.shrink()
                      : DropdownSearch<String?>(
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: 'City',
                              hintText: 'Select City',
                            ),
                          ),
                          selectedItem: selectedCity,
                          popupProps: const PopupProps.modalBottomSheet(
                            showSearchBox: true,
                            searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                labelText: 'City',
                                hintText: 'Select city',
                              ),
                            ),
                            searchDelay: Duration(milliseconds: 300),
                            isFilterOnline: true,
                          ),
                          asyncItems: (String filter) async {
                            final citySelection =
                                ref.watch(citySelectionProvider);
                            return citySelection.when(
                              data: (cityList) {
                                final filteredCities = cityList
                                    .where(
                                      (cities) => cities
                                          .toString()
                                          .toLowerCase()
                                          .startsWith(filter),
                                    )
                                    .toList();
                                final cityNameList = <String>[];
                                for (final city in filteredCities) {
                                  cityNameList.add(city as String);
                                }
                                return cityNameList;
                              },
                              loading: () => [
                                'Loading',
                              ],
                              error: (error, stackTrace) => [
                                'Error',
                              ],
                            );
                          },
                          onChanged: (value) {
                            ref.watch(locationProvider).city = value;
                            ref.watch(locationProvider).district = null;
                          },
                        ),
                  (location._country == null ||
                          location._country == '' ||
                          location._city == null ||
                          location._city == '')
                      ? const SizedBox.shrink()
                      : DropdownSearch<String?>(
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: 'District',
                              hintText: 'Select District',
                            ),
                          ),
                          selectedItem: selectedCity,
                          popupProps: const PopupProps.modalBottomSheet(
                            showSearchBox: true,
                            searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                labelText: 'City',
                                hintText: 'Select city',
                              ),
                            ),
                            searchDelay: Duration(milliseconds: 300),
                            isFilterOnline: true,
                          ),
                          asyncItems: (String filter) async {
                            final districtSelection =
                                ref.watch(districtSelectionProvider);

                            return districtSelection.when(
                              data: (List<dynamic> districtList) {
                                final filteredCountries = districtList
                                    .where(
                                      (cities) => cities
                                          .toString()
                                          .toLowerCase()
                                          .startsWith(filter),
                                    )
                                    .toList();
                                final countryNameList = <String>[];
                                for (final country in filteredCountries) {
                                  countryNameList.add(country as String);
                                }
                                return countryNameList;
                              },
                              loading: () => [
                                'Loading',
                              ],
                              error: (error, stackTrace) => [
                                'Error',
                              ],
                            );
                          },
                          onChanged: (value) {
                            ref.watch(locationProvider).district = value;
                          },
                        ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.4),
            TextButton(
              onPressed: () async {
                final status = await Permission.location.status;
                if (status.isDenied) {
                  // We didn't ask for permission yet or the permission has been denied before but not permanently.
                  await Permission.location.request();
                }

// You can can also directly ask the permission about its status.
                if (await Permission.location.isRestricted) {
                  // The OS restricts access, for example because of parental controls.
                  final location = await Geolocator.getCurrentPosition();

                  ref.read(locatorProvider)._position = location;
                  if (location != null) {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  } else {
                    await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Location Error'),
                        content: const Text(
                          'Please enable location services to continue',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                } else if (await Permission.location.isPermanentlyDenied) {
                  // The user opted to never again see the permission request dialog for this
                  // app. The only way to change the permission's status now is to let the
                  // user manually enable it in the system settings.
                  await openAppSettings();
                } else {
                  final location = await Geolocator.getCurrentPosition();

                  ref.read(locatorProvider)._position = location;

                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const HomeScreen(),
                    ),
                  );
                }
              },
              child: const Text('Use my location'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                fixedSize: Size(
                  MediaQuery.of(context).size.width,
                  50,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
              ),
              onPressed: (location.district?.isEmpty ?? true)
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    },
              child: const Text('Get Prayer Times'),
            )
          ],
        ),
      ),
    );
  }
}
