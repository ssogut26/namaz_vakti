import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:namaz_vakti/screens/location_selection.dart';

final homeScreenProvider = Provider<HomeScreen>((ref) => const HomeScreen());

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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

  @override
  Widget build(BuildContext context) {
    final prayerTimes = ref.watch(getPrayerTimes);
    return Scaffold(
      drawer: const Drawer(
        child: Column(
          children: [
            Text('Prayer Times'),
            Text('Settings'),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Column(
          children: [
            Text('Location'),
            Text('Date and Time'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: const Icon(Icons.menu),
          ),
        ],
      ),
      body: prayerTimes.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text(error.toString()),
        ),
        data: (times) {
          if (times?.times?.isEmpty ?? true) {
            return const Center(
              child: Text('No data'),
            );
          }
          int timeToMinutes(String time) {
            final parts = time.split(':');
            final hours = int.parse(parts[0]);
            final minutes = int.parse(parts[1]);
            return hours * 60 + minutes;
          }

          final timesOne = times?.times?.values.first;

          final start1 = timeToMinutes(timesOne?[1] ?? ''); // sunrise
          final end1 = timeToMinutes(timesOne?[4] ?? ''); // Maghrib
          final start2 = timeToMinutes(timesOne?[4] ?? ''); // Maghrib
          final end2 =
              timeToMinutes(timesOne?[1] ?? '') + 1440; // sunrise + 24 hours
          String removeDecimalZeroFormat(double n) {
            return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 1);
          }

          final value = timeToMinutes(
            DateFormat('HH:mm').format(DateTime.now()),
          );

          String minutesToTime(int minutes) {
            final hours = minutes ~/ 60;
            final mins = minutes % 60;
            return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
          }

          return Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                child: ListView.builder(
                  itemCount: 1,
                  itemBuilder: (context, index) {
                    return NextPrayerTimeCard(
                      times: times?.times?.values.first ?? [],
                      index: index,
                    );
                  },
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: ListView.builder(
                      itemCount: times?.times?.values.first.length,
                      itemBuilder: (context, index) {
                        return PrayerTimeCard(
                          times: times?.times?.values.first ?? [],
                          index: index,
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.52,
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 20,
                          thumbShape: MoonThumbShape(image: _moonImage),
                        ),
                        child: Slider(
                          min: start2.toDouble(),
                          max: end2.toDouble(),
                          value: double.parse(
                            value.toStringAsFixed(2),
                          ),
                          onChanged: null,
                          divisions: 6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class PrayerTimeCard extends StatelessWidget {
  const PrayerTimeCard({
    required this.times,
    required this.index,
    super.key,
  });

  final List<String> times;
  final int index;

  Widget times1(times) {
    switch (index) {
      case 0:
        return const Text(
          'Fajr',
        );
      case 1: // sunrise
        return const Text(
          'Sunrise',
        );
      case 2: // Dhuhr
        return const Text(
          'Dhuhr',
        );
      case 3:
        return const Text(
          'Asr',
        );
      case 4:
        return const Text(
          'Maghrib',
        );
      case 5:
        return const Text(
          'Isha',
        );

      default:
        return const Text(
          '',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ListTile(
          leading: const Icon(Icons.access_time),
          title: Center(
            child: times1(times),
          ),
          trailing: Text(
            times[index],
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
    );
  }
}

class NextPrayerTimeCard extends StatelessWidget {
  const NextPrayerTimeCard({
    required this.times,
    required this.index,
    super.key,
  });

  final List<String> times;
  final int index;

  Text checkTimes() {
    // Create a DateFormat object with the desired format
    final now = DateTime.now();
    final formattedTime = DateFormat('hh:mm').format(now);

// Parse the time from the list using the DateFormat object

    final time = DateFormat('hh:mm').parse(times[index]);

// Get the duration between the two times
    final duration = time.difference(DateTime.parse(formattedTime));

    switch (index) {
      case 0:
        time.isAfter(DateTime.parse(formattedTime));
        return Text(
          'Fajr in \n ${duration.inHours} hours ${duration.inMinutes} minutes',
        );
      case 1: // sunrise
        time.isAfter(DateTime.parse(formattedTime));

        return Text(
          'Sunrise in \n ${time.difference(DateTime.parse(formattedTime)).inHours} hours ${time.difference(DateTime.parse(formattedTime))} minutes)}',
        );
      case 2: // Dhuhr
        time.isAfter(DateTime.parse(formattedTime));

        return Text(
          'Dhuhr in \n ${time.difference(DateTime.parse(formattedTime)).inHours} hours ${time.difference(DateTime.parse(formattedTime)).inMinutes} minutes)}',
        );
      case 3:
        time.isAfter(DateTime.parse(formattedTime));

        return Text(
          'Asr in \n ${time.difference(DateTime.parse(formattedTime))} hours ${time.difference(DateTime.parse(formattedTime))} minutes)}',
        );

      case 4:
        time.isAfter(DateTime.parse(formattedTime));

        return Text(
          'Maghrib in \n ${time.difference(DateTime.parse(formattedTime)).inHours} hours ${time.difference(DateTime.parse(formattedTime)).inMinutes} minutes)}',
        );

      case 5:
        time.isAfter(DateTime.parse(formattedTime));

        return Text(
          'Isha in \n ${time.difference(DateTime.parse(formattedTime)).inHours} hours ${time.difference(DateTime.parse(formattedTime)).inMinutes} minutes)}',
        );

      default:
        return const Text(
          'Error',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          checkTimes(),
          Text(
            'Next Prayer Time in',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(
            '01 hours 30 minutes',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
