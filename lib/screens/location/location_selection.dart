// ignore_for_file: prefer_if_elements_to_conditional_expressions, invalid_use_of_protected_member

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namaz_vakti/models/countries.dart';
import 'package:namaz_vakti/screens/location/location_mixin.dart';
import 'package:namaz_vakti/screens/location/location_model.dart';
import 'package:namaz_vakti/screens/location/providers/location_providers.dart';

class LocationSelectionScreen extends ConsumerStatefulWidget {
  const LocationSelectionScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      LocationSelectionScreenState();
}

class LocationSelectionScreenState
    extends ConsumerState<LocationSelectionScreen> with LocationMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Selection'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const LocationRequirements(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.4),
            TextButton(
              onPressed: getPrayerTimesWithLocationFunction,
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
              onPressed: getPrayerTimesButton,
              child: const Text('Get Prayer Times'),
            )
          ],
        ),
      ),
    );
  }
}

class LocationRequirements extends ConsumerWidget {
  const LocationRequirements({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationValues = ref.watch(locationProvider.notifier);
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const CountrySelectionWidget(),
          (locationValues.state.country == null ||
                  locationValues.state.country == '')
              ? const SizedBox.shrink()
              : const CitySelectionWidget(),
          (locationValues.state.country == null ||
                  locationValues.state.country == '' ||
                  locationValues.state.city == null ||
                  locationValues.state.city == '')
              ? const SizedBox.shrink()
              : const DistrictSelectionWidget(),
        ],
      ),
    );
  }
}

class DistrictSelectionWidget extends ConsumerStatefulWidget {
  const DistrictSelectionWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DistrictSelectionWidgetState();
}

class _DistrictSelectionWidgetState
    extends ConsumerState<DistrictSelectionWidget> with DistrictMixin {
  @override
  Widget build(BuildContext context) {
    final locationValues = ref.watch(locationProvider.notifier);
    final districtSelection = ref.watch(
      districtSelectionProvider(
        LocationModel(
          country: locationValues.state.country,
          city: locationValues.state.city,
        ),
      ),
    );
    return DropdownSearch<String?>(
      dropdownDecoratorProps: const DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: 'District',
          hintText: 'Select District',
        ),
      ),
      selectedItem: locationValues.state.district,
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
        return districtSelection.when(
          data: (List<dynamic> districtList) {
            final filteredCountries = districtList
                .where(
                  (cities) =>
                      cities.toString().toLowerCase().startsWith(filter),
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
      onChanged: updateDistrict,
    );
  }
}

class CitySelectionWidget extends ConsumerStatefulWidget {
  const CitySelectionWidget({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CitySelectionWidgetState();
}

class _CitySelectionWidgetState extends ConsumerState<CitySelectionWidget>
    with CityMixin {
  @override
  Widget build(BuildContext context) {
    final locationValues = ref.watch(locationProvider.notifier);
    final citySelection =
        ref.watch(citySelectionProvider(locationValues.state.country ?? ''));
    return DropdownSearch<String?>(
      dropdownDecoratorProps: const DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: 'City',
          hintText: 'Select City',
        ),
      ),
      selectedItem: locationValues.state.city,
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
        return citySelection.when(
          skipLoadingOnRefresh: false,
          data: (cityList) {
            final filteredCities = cityList
                .where(
                  (cities) =>
                      cities.toString().toLowerCase().startsWith(filter),
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
      onChanged: updateCity,
    );
  }
}

class CountrySelectionWidget extends ConsumerStatefulWidget {
  const CountrySelectionWidget({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      CountrySelectionWidgetState();
}

class CountrySelectionWidgetState extends ConsumerState<CountrySelectionWidget>
    with CountryMixin {
  @override
  Widget build(BuildContext context) {
    final countrySelection = ref.watch(countrySelectionProvider);
    final locationValues = ref.watch(locationProvider.notifier);
    return DropdownSearch<String?>(
      dropdownDecoratorProps: const DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: 'Country',
          hintText: 'Select country',
        ),
      ),
      selectedItem: locationValues.state.country,
      popupProps: const PopupProps.modalBottomSheet(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            labelText: 'Country',
            hintText: 'Select country',
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
                      country?.name?.toLowerCase().startsWith(filter) ?? false,
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
      onChanged: updateCountry,
    );
  }
}
