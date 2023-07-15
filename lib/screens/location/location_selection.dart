// ignore_for_file: prefer_if_elements_to_conditional_expressions, invalid_use_of_protected_member

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namaz_vakti/extensions/extensions.dart';
import 'package:namaz_vakti/generated/locale_keys.g.dart';
import 'package:namaz_vakti/models/countries.dart';
import 'package:namaz_vakti/mixins/location_mixin.dart';
import 'package:namaz_vakti/models/location_model.dart';
import 'package:namaz_vakti/providers/location_providers.dart';

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
        title: Text(LocaleKeys.locationSelection_selectLocation.locale),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const LocationRequirements(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.4),
            AppElevatedButton(
              onPressed: getPrayerTimesButton,
              text: LocaleKeys.locationSelection_getPrayerTimes.locale,
            )
          ],
        ),
      ),
    );
  }
}

class AppElevatedButton extends StatelessWidget {
  const AppElevatedButton({
    required this.onPressed,
    required this.text,
    this.color,
    super.key,
  });

  final void Function()? onPressed;
  final String? text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: color == null
              ? const BorderRadius.all(
                  Radius.circular(16),
                )
              : BorderRadius.zero,
        ),
      ),
      onPressed: onPressed,
      child: Center(
        child: Text(
          text ?? '',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
              ),
        ),
      ),
    );
  }
}

class LocationRequirements extends ConsumerStatefulWidget {
  const LocationRequirements({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _LocationRequirementsState();
}

class _LocationRequirementsState extends ConsumerState<LocationRequirements>
    with LocationRequirementsMixin {
  @override
  Widget build(BuildContext context) {
    final locationValues = ref.watch(locationProvider.notifier);
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CountrySelectionWidget(callBack: updateCountry),
          (locationValues.state.country.isEmptyOrNull)
              ? const SizedBox.shrink()
              : CitySelectionWidget(callBack: updateCity),
          (locationValues.state.city.isEmptyOrNull)
              ? const SizedBox.shrink()
              : DistrictSelectionWidget(callBack: updateDistrict),
        ],
      ),
    );
  }
}

class DistrictSelectionWidget extends ConsumerWidget {
  const DistrictSelectionWidget({required this.callBack, super.key});
  final void Function(String?)? callBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: LocaleKeys.locationSelection_district.locale,
          hintText: LocaleKeys.locationSelection_selectDistrict.locale,
        ),
      ),
      selectedItem: locationValues.state.district,
      popupProps: PopupProps.modalBottomSheet(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            labelText: LocaleKeys.locationSelection_district.locale,
            hintText: LocaleKeys.locationSelection_selectDistrict.locale,
          ),
        ),
        itemBuilder: (context, country, isSelected) {
          return ListTile(
            title: Text(country ?? ''),
          );
        },
        searchDelay: const Duration(milliseconds: 300),
        emptyBuilder: (context, country) {
          return ListTile(
            title: Text(
              LocaleKeys.locationSelection_empty.locale,
              textAlign: TextAlign.center,
            ),
          );
        },
        isFilterOnline: true,
      ),
      asyncItems: (String filter) async {
        return districtSelection.when(
          skipLoadingOnRefresh: true,
          data: (List<dynamic> districtList) {
            final filteredDistricts = districtList
                .where(
                  (cities) =>
                      cities.toString().toLowerCase().startsWith(filter),
                )
                .toList();
            final districtNameList = <String>[];
            for (final district in filteredDistricts) {
              districtNameList.add(district as String);
            }
            return districtNameList;
          },
          loading: () => [
            LocaleKeys.locationSelection_loading.locale,
          ],
          error: (error, stackTrace) => [
            LocaleKeys.locationSelection_error.locale,
          ],
        );
      },
      onBeforeChange: (String? prev, String? next) async {
        if (prev != next) {
          await ref.read(locationProvider.notifier).changeDistrict(next);
        }
        return true;
      },
      onChanged: callBack,
    );
  }
}

class CitySelectionWidget extends ConsumerWidget {
  const CitySelectionWidget({required this.callBack, super.key});
  final void Function(String?)? callBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationValues = ref.watch(locationProvider.notifier);
    final citySelection =
        ref.watch(citySelectionProvider(locationValues.state.country ?? ''));
    return DropdownSearch<String?>(
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: LocaleKeys.locationSelection_city.locale,
          hintText: LocaleKeys.locationSelection_selectCity.locale,
        ),
      ),
      selectedItem: locationValues.state.city,
      popupProps: PopupProps.modalBottomSheet(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            labelText: LocaleKeys.locationSelection_city.locale,
            hintText: LocaleKeys.locationSelection_selectCity.locale,
          ),
        ),
        itemBuilder: (context, country, isSelected) {
          return ListTile(
            title: Text(country ?? ''),
          );
        },
        emptyBuilder: (context, country) {
          return ListTile(
            title: Text(
              LocaleKeys.locationSelection_empty.locale,
              textAlign: TextAlign.center,
            ),
          );
        },
        searchDelay: const Duration(milliseconds: 300),
        isFilterOnline: true,
      ),
      asyncItems: (String filter) async {
        return citySelection.when(
          skipLoadingOnRefresh: true,
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
            LocaleKeys.locationSelection_loading.locale,
          ],
          error: (error, stackTrace) => [
            LocaleKeys.locationSelection_error.locale,
          ],
        );
      },
      onBeforeChange: (String? prev, String? next) async {
        if (prev != next) {
          await ref.read(locationProvider.notifier).changeCity(next);
        }
        return true;
      },
      onChanged: callBack,
    );
  }
}

class CountrySelectionWidget extends ConsumerWidget {
  const CountrySelectionWidget({required this.callBack, super.key});
  final void Function(String?)? callBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countrySelection = ref.watch(countrySelectionProvider);
    final locationValues = ref.watch(locationProvider.notifier);
    return DropdownSearch<String?>(
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: LocaleKeys.locationSelection_country.locale,
          hintText: LocaleKeys.locationSelection_selectCountry.locale,
        ),
      ),
      selectedItem: locationValues.state.country,
      popupProps: PopupProps.modalBottomSheet(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            labelText: LocaleKeys.locationSelection_country.locale,
            hintText: LocaleKeys.locationSelection_selectCountry.locale,
          ),
        ),
        itemBuilder: (context, country, isSelected) {
          return ListTile(
            title: Text(country ?? ''),
          );
        },
        emptyBuilder: (context, country) {
          return ListTile(
            title: Text(
              LocaleKeys.locationSelection_empty.locale,
              textAlign: TextAlign.center,
            ),
          );
        },
        searchDelay: const Duration(milliseconds: 300),
        isFilterOnline: true,
      ),
      asyncItems: (String filter) async {
        return countrySelection.when(
          skipLoadingOnRefresh: true,
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
            LocaleKeys.locationSelection_loading.locale,
          ],
          error: (error, stackTrace) => [
            LocaleKeys.locationSelection_error.locale,
          ],
        );
      },
      onBeforeChange: (String? prev, String? next) async {
        if (prev != next) {
          await ref.read(locationProvider.notifier).changeCountry(next);
        }
        return true;
      },
      onChanged: callBack,
    );
  }
}
