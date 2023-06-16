// ignore_for_file: prefer_if_elements_to_conditional_expressions

import 'dart:ui' as ui;

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:namaz_vakti/models/countries.dart';
import 'package:namaz_vakti/services/api.dart';
import 'package:rive/rive.dart';

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

final getPrayerTimes =
    FutureProvider.family.autoDispose((ref, String dates) async {
  final country = ref.watch(locationProvider).country;
  final city = ref.watch(locationProvider).city;
  final district = ref.watch(locationProvider).district;
  // if (country != null && city != null && district != null) {
  final prayerTimes = await ApiService.instance.getPrayerTimes(
    'Turkey',
    'Ankara',
    'Ankara',
    dates,
  );

  return prayerTimes;
  // } else if (country == '' && city == '' && district == '') {
  //   return null;
  // } else {
  //   return null;
  // }
});

class LocationSelectionScreen extends ConsumerStatefulWidget {
  const LocationSelectionScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      LocationSelectionScreenState();
}

class LocationSelectionScreenState
    extends ConsumerState<LocationSelectionScreen> {
  ui.Image? _sunImage;
  ui.Image? _moonImage;

  // A method to load the image asset
  Future<void> _loadSunImage() async {
    // Get the byte data of the image file
    final data = await rootBundle.load('assets/sun.png');
    // Decode the image data and create an image object
    final image = await decodeImageFromList(data.buffer.asUint8List());
    // Update the state with the image object
    setState(() {
      _sunImage = image;
    });
  }

  Future<void> loadMoonImage() async {
    final data = await rootBundle.load('assets/moon.png');
    final image = await decodeImageFromList(data.buffer.asUint8List());
    setState(() {
      _moonImage = image;
    });
  }

  @override
  void initState() {
    super.initState();
    // Load the image when the widget is initialized
    _loadSunImage();
    loadMoonImage();
  }

  String? selectedCountry;
  String? selectedCity;
  String? selectedDistrict;

  @override
  Widget build(BuildContext context) {
    final countrySelection = ref.watch(countrySelectionProvider);
    final citySelection = ref.watch(citySelectionProvider);
    final districtSelection = ref.watch(districtSelectionProvider);
    final location = ref.watch(locationProvider);
    final prayerTimes = ref
        .watch(getPrayerTimes(DateFormat('yyyy-MM-dd').format(DateTime.now())));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Selection'),
      ),
      body: Column(
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
                            country?.name?.toLowerCase().startsWith(filter) ??
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
                    return citySelection.when(
                      data: (List<dynamic> cityList) {
                        final filteredCountries = cityList
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
          (location._country == null ||
                  location._country == '' ||
                  location._city == null ||
                  location._city == '' ||
                  location._district == null ||
                  location._district == '')
              ? const SizedBox.shrink()
              : prayerTimes.when(
                  data: (times) {
                    int timeToMinutes(String time) {
                      final parts = time.split(':');
                      final hours = int.parse(parts[0]);
                      final minutes = int.parse(parts[1]);
                      return hours * 60 + minutes;
                    }

                    final timesOne = times?.times?.values.first;
                    timesOne?.add('24:00');
                    final start1 = timeToMinutes(timesOne?[1] ?? ''); // sunrise
                    final end1 = timeToMinutes(timesOne?[4] ?? ''); // Maghrib
                    final start2 = timeToMinutes(timesOne?[4] ?? ''); // Maghrib
                    final end2 = timeToMinutes(timesOne?[1] ?? '') +
                        1440; // sunrise + 24 hours
                    String removeDecimalZeroFormat(double n) {
                      return n
                          .toStringAsFixed(n.truncateToDouble() == n ? 0 : 1);
                    }

                    final value = timeToMinutes(
                      DateFormat('HH:mm').format(DateTime.now()),
                    );
                    print({value < end1});
                    String minutesToTime(int minutes) {
                      final hours = minutes ~/ 60;
                      final mins = minutes % 60;
                      return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
                    }

                    return Column(
                      children: [
                        for (int i = 0; i < (timesOne?.length ?? 0); i++)
                          Text(
                            () {
                              switch (i) {
                                case 0:
                                  return 'Fajr: ${timesOne?[i]}';
                                case 1:
                                  return 'Sunrise: ${timesOne?[i]}';
                                case 2:
                                  return 'Dhuhr: ${timesOne?[i]}';
                                case 3:
                                  return 'Asr: ${timesOne?[i]}';
                                case 4:
                                  return 'Maghrib: ${timesOne?[i]}';
                                case 5:
                                  return 'Isha: ${timesOne?[i]}';
                                default:
                                  return '';
                              }
                            }(),
                          ),
                        value < end1 == true
                            ? const RiveAnimation.asset(
                                'assets/test.riv',
                                fit: BoxFit.cover,
                              )
                            : SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                child: RotatedBox(
                                  quarterTurns: 1,
                                  child: SliderTheme(
                                    data: SliderThemeData(
                                      trackHeight: 10,
                                      thumbShape:
                                          MoonThumbShape(image: _moonImage),
                                    ),
                                    child: Slider(
                                      min: start2.toDouble(),
                                      max: end2.toDouble(),
                                      value: double.parse(
                                        value.toStringAsFixed(2),
                                      ),
                                      onChanged: null,
                                      divisions: 7,
                                    ),
                                  ),
                                ),
                              ),
                        const Row(),
                      ],
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stackTrace) => Text('Error$error'),
                ),
        ],
      ),
    );
  }
}

class SunThumbShape extends SliderComponentShape {
  // A constructor that takes the image object as a parameter
  SunThumbShape({this.image});
  // The image object to draw
  final ui.Image? image;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    // Return the preferred size of the thumb shape
    return const Size(48, 48);
  }

  @override
  void paint(
    PaintingContext context,
    ui.Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required ui.TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required ui.Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    // Create a paint object with some properties

    // Draw a circle on the canvas with the center and radius
    canvas.drawCircle(center, 24 * 2, Paint()..color = Colors.transparent);
    // If the image object is not null, draw it on top of the circle
    if (image != null) {
      paintImage(
        canvas: canvas,
        rect: Rect.fromCenter(center: center, width: 48, height: 48),
        image: image!,
        fit: BoxFit.cover,
      );
    }

    // I want to bend slider
  }
}

class MoonThumbShape extends SliderComponentShape {
  // A constructor that takes the image object as a parameter
  MoonThumbShape({this.image});
  // The image object to draw
  final ui.Image? image;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    // Return the preferred size of the thumb shape
    return const Size(48, 48);
  }

  @override
  void paint(
    PaintingContext context,
    ui.Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required ui.TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required ui.Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    // Create a paint object with some properties

    // Draw a circle on the canvas with the center and radius
    canvas.drawCircle(center, 24 * 2, Paint()..color = Colors.transparent);
    // If the image object is not null, draw it on top of the circle
    if (image != null) {
      paintImage(
        canvas: canvas,
        rect: Rect.fromCenter(center: center, width: 48, height: 48),
        image: image!,
        fit: BoxFit.cover,
      );
    }
  }
}
