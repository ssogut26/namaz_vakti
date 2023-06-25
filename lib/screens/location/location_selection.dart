// ignore_for_file: prefer_if_elements_to_conditional_expressions

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:namaz_vakti/models/countries.dart';
import 'package:namaz_vakti/screens/home/view/home_screen.dart';
import 'package:namaz_vakti/services/api.dart';
import 'package:permission_handler/permission_handler.dart';

class CountryNotifier extends StateNotifier<String> {
  CountryNotifier(
    super._country,
  );

  String _country = '';

  String get setCountry => _country;

  set setCountry(String country) {
    _country = country;
  }
}

final countryProvider = StateNotifierProvider<CountryNotifier, String>(
  (ref) => CountryNotifier(''),
);

class CityNotifier extends StateNotifier<String> {
  CityNotifier(
    super._city,
  );

  String _city = '';

  String get setCity => _city;

  set setCity(String city) {
    _city = city;
  }
}

final cityProvider = StateNotifierProvider<CityNotifier, String>(
  (ref) => CityNotifier(''),
);

class DistrictNotifier extends StateNotifier<String> {
  DistrictNotifier(
    super._district,
  );

  String _district = '';

  String get setDistrict => _district;

  set setDistrict(String district) {
    _district = district;
  }
}

final districtProvider = StateNotifierProvider<DistrictNotifier, String>(
  (ref) => DistrictNotifier(''),
);

final countrySelectionProvider = FutureProvider(
  (ref) async {
    final countries = await ApiService.instance.getCountries();
    return countries;
  },
);

final citySelectionProvider = FutureProvider((ref) async {
  final country = ref.watch(countryProvider.notifier)._country;
  if (country == '') {
    return null;
  }
  final cities = await ApiService.instance.getCities(country);
  return cities;
});

final districtSelectionProvider = FutureProvider((ref) async {
  final country = ref.watch(countryProvider.notifier)._country;
  final city = ref.watch(cityProvider.notifier)._city;
  final districts = await ApiService.instance.getDistrict(country, city);
  return districts;
});

final getPrayerTimesWithSelection =
    FutureProvider.family.autoDispose((ref, String dates) async {
  final country = ref.watch(countryProvider.notifier)._country;
  final city = ref.watch(cityProvider.notifier)._city;
  final district = ref.watch(districtProvider.notifier)._district;
  if (country == '' || city == '' || district == '') {
    return null;
  } else {
    final prayerTimes = await ApiService.instance.getPrayerTimes(
      country,
      city,
      district,
      dates,
    );
    return prayerTimes;
  }
});

final getPrayerTimesWithLocation =
    FutureProvider.family.autoDispose((ref, String dates) async {
  final locator = ref.watch(locatorProvider.notifier)._position;
  final prayerTimes = await ApiService.instance.getPrayerTimesByLocation(
    latitude: locator?.latitude.toString() ?? '',
    longitude: locator?.longitude.toString() ?? '',
    date: dates,
  );
  return prayerTimes;
});

class LocatorNotifier extends StateNotifier<bool> {
  LocatorNotifier(super.isLocationEnabled);

  bool _isLocationEnabled = false;
  bool get isLocationEnabled => _isLocationEnabled;
  set isLocationEnabled(bool value) {
    _isLocationEnabled = value;
  }

  Position? _position;
  Position? get position => _position;
  set position(Position? value) {
    _position = value;
  }
}

final locatorProvider = StateNotifierProvider(
  (ref) => LocatorNotifier(
    false,
  ),
);

class LocationSelectionScreen extends ConsumerStatefulWidget {
  const LocationSelectionScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      LocationSelectionScreenState();
}

class LocationSelectionScreenState
    extends ConsumerState<LocationSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    final countrySelection = ref.watch(countrySelectionProvider);
    final countryP = ref.watch(countryProvider.notifier);
    final cityP = ref.watch(cityProvider.notifier);
    final districtP = ref.watch(districtProvider.notifier);
    // final location = ref.watch(locationProvider);

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
                    selectedItem: countryP._country,
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
                      ref.read(countryProvider.notifier);
                      ref.read(cityProvider.notifier).setCity = '';
                      ref.read(districtProvider.notifier).setDistrict = '';
                    },
                  ),
                  (countryP._country == '')
                      ? const SizedBox.shrink()
                      : DropdownSearch<String?>(
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: 'City',
                              hintText: 'Select City',
                            ),
                          ),
                          selectedItem: cityP._city,
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
                                    ?.where(
                                      (cities) => cities
                                          .toString()
                                          .toLowerCase()
                                          .startsWith(filter),
                                    )
                                    .toList();
                                final cityNameList = <String>[];
                                for (final city in filteredCities ?? []) {
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
                            ref.read(cityProvider.notifier).setCity =
                                value ?? '';
                            ref.read(districtProvider.notifier).setDistrict =
                                '';
                          },
                        ),
                  (countryP._country == '' || cityP._city == '')
                      ? const SizedBox.shrink()
                      : DropdownSearch<String?>(
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: 'District',
                              hintText: 'Select District',
                            ),
                          ),
                          selectedItem: districtP._district,
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
                            ref.read(districtProvider.notifier).setDistrict =
                                value ?? '';
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

                  ref.read(locatorProvider.notifier)._position = location;
                  if (location != null) {
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const HomeScreen(
                          isLocation: true,
                        ),
                      ),
                    );
                  } else {
                    await showDialog<void>(
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

                  ref.read(locatorProvider.notifier)._position = location;

                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const HomeScreen(
                        isLocation: true,
                      ),
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
              onPressed: (countryP._country == '' ||
                      cityP._city == '' ||
                      districtP._district == '')
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => const HomeScreen(
                            isLocation: false,
                          ),
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
