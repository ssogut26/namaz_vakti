import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:namaz_vakti/screens/location_selection.dart';

final homeScreenProvider = Provider<HomeScreen>((ref) => const HomeScreen());

class CurrentTimeNotifier extends StateNotifier<int> {
  CurrentTimeNotifier() : super(0);

  int get time => state;
  int timeToMinutes(String time) {
    final parts = time.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    return hours * 60 + minutes;
  }

  int getTime() {
    state = timeToMinutes(
      DateFormat('HH:mm').format(DateTime.now()),
    );
    print(state);
    return state;
  }
}

class CurrentTimeNotifier1 extends ChangeNotifier {
  CurrentTimeNotifier1() {
    _updateTime(); // Update the time initially
    _startTimer(); // Start the timer to update the time periodically
  }
  int? _time;
  int get time => _time ?? 0;

  void _updateTime() {
    // Get the current time and set it as the new time value
    _time = DateTime.now().millisecondsSinceEpoch;
    notifyListeners();
  }

  void _startTimer() {
    // Start a timer to update the time every second
    const duration = Duration(seconds: 1);
    Timer.periodic(duration, (_) {
      _updateTime();
    });
  }
}

final currentTimeProvider =
    ChangeNotifierProvider((ref) => CurrentTimeNotifier1());

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

  String? date = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    // Load the image when the widget is initialized
    _loadSunImage();
    loadMoonImage();
  }

  @override
  Widget build(BuildContext context) {
    final currentTime = ref.watch(currentTimeProvider);
    final prayerTimes = ref.watch(
      getPrayerTimes(
        date ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
      ),
    );
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
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: prayerTimes.when(
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

            final sunrise = timeToMinutes(timesOne?[1] ?? ''); // sunrise
            final maghrib = timeToMinutes(timesOne?[4] ?? ''); // Maghrib

            String removeDecimalZeroFormat(double n) {
              return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 1);
            }

            // final currentTime = timeToMinutes(
            //   DateFormat('HH:mm').format(DateTime.now()),
            // );

            String minutesToTime(int minutes) {
              final hours = minutes ~/ 60;
              final mins = minutes % 60;
              return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
            }

            ref.watch(currentTimeProvider)._startTimer();

            final time = ref.watch(currentTimeProvider)._time =
                timeToMinutes(DateFormat('HH:mm').format(DateTime.now()));

            return PageView.builder(
              onPageChanged: (index) {
                date = DateFormat('yyyy-MM-dd').format(
                  DateTime.now().add(
                    Duration(days: index),
                  ),
                );
              },
              itemCount: times?.times?.values.length,
              itemBuilder: (context, pageIndex) {
                final a = times?.times?.values.map((e) => e).toList();

                return Column(
                  children: [
                    if (pageIndex == 0)
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.2,
                        child: NextPrayerTimeCard(
                          times: a ?? [],
                          index: pageIndex,
                        ),
                      )
                    else
                      Card(
                        child: Center(
                          child: Text(date ?? ''),
                        ),
                      ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // ignore: lines_longer_than_80_chars
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.65,
                          width: pageIndex == 0
                              ? MediaQuery.of(context).size.width * 0.80
                              : MediaQuery.of(context).size.width * 0.95,
                          child: ListView.builder(
                            // There is 6 value on each day so
                            // we need to set itemCount to 6
                            itemCount: 6,
                            itemBuilder: (context, index) {
                              return PrayerTimeCard(
                                times:
                                    times?.times?.values.elementAt(pageIndex) ??
                                        [],
                                index: index,
                              );
                            },
                          ),
                        ),
                        if (time < maghrib && pageIndex == 0)
                          Padding(
                            padding: const EdgeInsets.all(2),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * .65,
                              child: RotatedBox(
                                quarterTurns: 1,
                                child: SliderTheme(
                                  data: SliderThemeData(
                                    trackHeight: 20,
                                    thumbShape: SunThumbShape(image: _sunImage),
                                  ),
                                  child: Slider(
                                    min: sunrise.toDouble(),
                                    max: maghrib.toDouble(),
                                    value: time.toDouble(),
                                    onChanged: null,
                                    divisions: maghrib - sunrise,
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          pageIndex == 0
                              ? MoonSlider(
                                  start2: 0,
                                  end2: 1440 - sunrise,
                                  value: time - maghrib,
                                  moonImage: _moonImage,
                                )
                              : const Text(''),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class MoonSlider extends ConsumerWidget {
  const MoonSlider({
    required this.start2,
    required this.end2,
    required this.value,
    required ui.Image? moonImage,
    super.key,
  }) : _moonImage = moonImage;

  final int start2;
  final int end2;
  final int value;
  final ui.Image? _moonImage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // print(end2 + (end2 - start2) - 1440);
    final currentTime = ref.watch(currentTimeProvider.notifier).time - end2;
    return Padding(
      padding: const EdgeInsets.all(2),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .65,
        child: RotatedBox(
          quarterTurns: 3,
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 20,
              thumbShape: MoonThumbShape(
                image: _moonImage,
              ),
            ),
            child: Slider(
              min: start2.toDouble(),
              max: end2.toDouble(),
              value: currentTime.toDouble(),
              onChanged: null,
              divisions: end2 - start2,
            ),
          ),
        ),
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

  Widget times1() {
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
      color: Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ListTile(
          leading: const Icon(Icons.access_time),
          title: Center(
            child: times1(),
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

class NextPrayerTimeCard extends StatefulWidget {
  const NextPrayerTimeCard({
    required this.times,
    required this.index,
    super.key,
  });

  final List<List<String>> times;
  final int index;

  @override
  State<NextPrayerTimeCard> createState() => _NextPrayerTimeCardState();
}

class _NextPrayerTimeCardState extends State<NextPrayerTimeCard>
    with TickerProviderStateMixin {
  Timer? _timer;
  Duration? nextTime;
  AnimationController? _controller;

  Text checkTimes() {
    // get current time and format as hh:mm
    final currentTime = DateFormat('HH:mm').format(DateTime.now());
    final durationNow = Duration(
      hours: int.parse(currentTime.split(':')[0]),
      minutes: int.parse(currentTime.split(':')[1]),
    );

    for (var i = 0; i < widget.times.length; i++) {
      final durations = Duration(
        hours: int.parse(
          widget.times[0][i].split(':')[0],
        ),
        minutes: int.parse(
          widget.times[0][i].split(':')[1],
        ),
      );

      final difference = durations - durationNow;
      nextTime = difference;
      if (difference.isNegative) {
        final nextDayDurations = Duration(
          hours: int.parse(
            widget.times[1][0].split(':')[0],
          ),
          minutes: int.parse(
            widget.times[1][0].split(':')[1],
          ),
        );

        final dif = nextDayDurations - durationNow;
        nextTime = dif;
      } else {
        return const Text(
          'Next Prayer Time in',
        );
      }
    }
    return const Text('Next Prayer Time in ');
  }

  int getRemainingTime(Duration endTime) {
    final difference = endTime;

    if (difference.isNegative) {
      setState(() {});
    }

    final hours = difference.inHours.remainder(24);
    final minutes = difference.inMinutes.remainder(60);
    final seconds = difference.inSeconds.remainder(60);

    return hours * 3600 + minutes * 60 + seconds;
  }

  @override
  void initState() {
    super.initState();
    checkTimes();
    _timer = Timer.periodic(nextTime ?? const Duration(), (Timer timer) {
      setState(() {});
    });
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        seconds: getRemainingTime(nextTime ?? const Duration()),
      ),
    );

    _controller?.forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Countdown(
            animation: StepTween(
              begin: getRemainingTime(nextTime ?? const Duration()),
              end: 0,
            ).animate(_controller!),
          ),
        ],
      ),
    );
  }
}

class Countdown extends AnimatedWidget {
  Countdown({super.key, this.animation}) : super(listenable: animation!);
  final Animation<int>? animation;

  @override
  Text build(BuildContext context) {
    final clockTimer = Duration(seconds: animation?.value ?? 0);

    final timerText = clockTimer.inHours != 0
        ? '${clockTimer.inHours.remainder(24).toString().padLeft(2, '0')}:${clockTimer.inMinutes.remainder(60).toString().padLeft(2, '0')}'
        : '${clockTimer.inMinutes.remainder(60).toString().padLeft(2, '0')}:${clockTimer.inSeconds.remainder(60).toString().padLeft(2, '0')}';

    return Text(
      timerText,
      style: TextStyle(
        fontSize: 70,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}
