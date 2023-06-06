// ignore_for_file: prefer_if_elements_to_conditional_expressions

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namaz_vakti/models/countries.dart';
import 'package:namaz_vakti/services/api.dart';

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
  if (country == null) {
    return <String>[];
  }
  final cities = await ApiService.instance.getCities(country);
  return cities;
});

final districtSelectionProvider = FutureProvider((ref) async {
  final country = ref.watch(locationProvider).country;
  final city = ref.watch(locationProvider).city;
  final districts =
      await ApiService.instance.getDistrict(country ?? '', city ?? '');
  return districts;
});

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
  List<String> createdCountryList = [];
  @override
  Widget build(BuildContext context) {
    final countrySelection = ref.watch(countrySelectionProvider);
    final citySelection = ref.watch(citySelectionProvider);
    final districtSelection = ref.watch(districtSelectionProvider);
    final location = ref.watch(locationProvider);
    return Scaffold(
      body: Column(
        children: [
          DropdownButton<String>(
            items: countrySelection.when(
              data: (List<CountriesModel?> countryList) {
                createdCountryList.addAll(countryList.map((e) => e!.name!));
                return createdCountryList.map((country) {
                  return DropdownMenuItem<String>(
                    key: ValueKey(country),
                    value: country,
                    child: Text(country),
                    onTap: () {
                      setState(() {
                        createdCountryList.remove(country);
                      });
                    },
                  );
                }).toList();
              },
              loading: () => [
                const DropdownMenuItem<String>(
                  value: 'Loading',
                  child: Text('Loading'),
                )
              ],
              error: (error, stackTrace) => [
                const DropdownMenuItem<String>(
                  value: 'Error',
                  child: Text('Error'),
                )
              ],
            ),
            onChanged: (value) {
              setState(() {
                selectedCountry = value!;
              });
              ref.read(locationProvider).country = value!;
            },
          ),
          (selectedCountry != null || selectedCountry != '')
              ? DropdownButton<String>(
                  hint: const Text('Select City'),
                  value: location._city,
                  items: citySelection.when(
                    data: (List<dynamic> cityList) {
                      return cityList.map((cities) {
                        final cityValue = cities as String;
                        return DropdownMenuItem<String>(
                          value: cityValue,
                          key: ValueKey(cityValue),
                          onTap: () {
                            setState(() {
                              cityList.remove(cities);
                              selectedCity = cityValue;
                              ref.read(locationProvider).city = cityValue;
                            });
                          },
                          child: Text(cityValue),
                        );
                      }).toList();
                    },
                    loading: () => [
                      const DropdownMenuItem<String>(
                        value: 'Loading',
                        child: Text('Loading'),
                      )
                    ],
                    error: (error, stackTrace) => [
                      DropdownMenuItem<String>(
                        value: 'Error',
                        child: Text('Error$error'),
                      )
                    ],
                  ),
                  onChanged: (value) {
                    if (ref.read(locationProvider).city == null ||
                        ref.read(locationProvider).city == '') {
                      ref.read(locationProvider).city = value;
                    } else {
                      ref.read(locationProvider).city = '';
                    }
                  },
                )
              : const SizedBox.shrink(),
          (selectedCountry != null ||
                  selectedCountry != '' && selectedCity != null ||
                  selectedCity != '')
              ? DropdownButton<dynamic>(
                  hint: const Text('Select district'),
                  value: location.district,
                  items: districtSelection.when(
                    data: (List<dynamic> districtList) {
                      return districtList.map((district) {
                        return DropdownMenuItem<dynamic>(
                          key: ValueKey(district),
                          onTap: () {
                            districtList.remove(district);
                          },
                          value: district,
                          child: Text(district as String),
                        );
                      }).toList();
                    },
                    loading: () => [
                      const DropdownMenuItem<String>(
                        value: 'Loading',
                        child: Text('Loading'),
                      )
                    ],
                    error: (error, stackTrace) => [
                      DropdownMenuItem<String>(
                        value: 'Error',
                        child: Text('Error$error'),
                      )
                    ],
                  ),
                  onChanged: (value) {
                    if (ref.read(locationProvider).district == null ||
                        ref.read(locationProvider).district == '') {
                      ref.read(locationProvider).district = value as String;
                    } else {
                      ref.read(locationProvider).district = '';
                    }
                  },
                )
              : const SizedBox.shrink()
        ],
      ),
    );
  }
}
