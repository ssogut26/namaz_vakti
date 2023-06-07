// ignore_for_file: prefer_if_elements_to_conditional_expressions

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
    final countryList = <DropdownMenuItem<String>>[];
    for (final country in countries) {
      countryList.add(
        DropdownMenuItem<String>(
          key: ValueKey(country),
          value: country?.name,
          child: Text(country?.name ?? ''),
        ),
      );
    }
    return countryList;
  },
);

final citySelectionProvider = FutureProvider((ref) async {
  final country = ref.watch(locationProvider).country;
  final cities = await ApiService.instance.getCities(country ?? '');
  final cityList = <DropdownMenuItem<String>>[];
  for (final city in cities) {
    cityList.add(
      DropdownMenuItem<String>(
        key: ValueKey(city),
        value: city.toString(),
        child: Text(city.toString()),
      ),
    );
  }
  return cityList;
});

final districtSelectionProvider = FutureProvider((ref) async {
  final country = ref.watch(locationProvider).country;
  final city = ref.watch(locationProvider).city;
  final districts =
      await ApiService.instance.getDistrict(country ?? '', city ?? '');
  final districtList = <DropdownMenuItem<String>>[];
  for (final district in districts) {
    districtList.add(
      DropdownMenuItem<String>(
        key: ValueKey(district),
        value: district.toString(),
        child: Text(district.toString()),
      ),
    );
  }
  return districtList;
});

final getPrayerTimes = FutureProvider((ref) async {
  final country = ref.watch(locationProvider).country;
  final city = ref.watch(locationProvider).city;
  final district = ref.watch(locationProvider).district;
  if (country != null && city != null && district != null) {
    final prayerTimes = await ApiService.instance.getPrayerTimes(
      country,
      city,
      district,
      DateFormat('yMMMMd').format(DateTime.now()),
    );
    return prayerTimes;
  } else if (country == '' && city == '' && district == '') {
    return null;
  } else {
    return null;
  }
});

class LocationSelectionScreen extends ConsumerStatefulWidget {
  const LocationSelectionScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      LocationSelectionScreenState();
}

class LocationSelectionScreenState
    extends ConsumerState<LocationSelectionScreen> {
  ui.Image? _image;

  // A method to load the image asset
  Future<void> _loadImage() async {
    // Get the byte data of the image file
    final data = await rootBundle.load('assets/sun.png');
    // Decode the image data and create an image object
    final image = await decodeImageFromList(data.buffer.asUint8List());
    // Update the state with the image object
    setState(() {
      _image = image;
    });
  }

  @override
  void initState() {
    super.initState();
    // Load the image when the widget is initialized
    _loadImage();
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
    final prayerTimes = ref.watch(getPrayerTimes);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Selection'),
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            hint: Text(location._country ?? 'Select Country'),
            items: countrySelection.when(
              data: (countryList) {
                return countryList;
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
              ref.watch(locationProvider).country = value;
              ref.watch(locationProvider).city = null;
            },
          ),
          (location._country == null || location._country == '')
              ? const SizedBox.shrink()
              : DropdownButton<String>(
                  hint: Text(location._city ?? 'Select City'),
                  items: citySelection.when(
                    data: (cityList) {
                      return cityList;
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
                    ref.watch(locationProvider).city = value;
                    ref.watch(locationProvider).district = null;
                  },
                ),
          (location._country == null ||
                  location._country == '' ||
                  location._city == null ||
                  location._city == '')
              ? const SizedBox.shrink()
              : DropdownButton<String>(
                  hint: Text(location._district ?? 'Select District'),
                  items: districtSelection.when(
                    data: (districtList) {
                      return districtList;
                    },
                    loading: () => [
                      const DropdownMenuItem<String>(
                        value: 'Loading',
                        child: CircularProgressIndicator(),
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

                    final value = timeToMinutes(
                      DateFormat('HH:mm').format(DateTime.now()),
                    ).toDouble();
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
                        value < end1
                            ? Slider(
                                min: start1.toDouble(),
                                max: end1.toDouble(),
                                value: value,
                                onChanged: null,
                              )
                            : SliderTheme(
                                data: SliderThemeData(
                                  thumbShape: SunThumbShape(image: _image),
                                ),
                                child: Slider(
                                  min: start2.toDouble(),
                                  max: end2.toDouble(),
                                  value: value,
                                  onChanged: null,
                                ),
                              ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              minutesToTime(start2),
                            ),
                            Text(
                              minutesToTime(end2),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stackTrace) => Text('Error$error'),
                ),
          TextButton(
            onPressed: () {},
            child: const Text('reset'),
          )
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
    final paint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;
    // Draw a circle on the canvas with the center and radius
    canvas.drawCircle(center, 24, paint);
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
