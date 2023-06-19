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
  const HomeScreen({super.key, this.isLocation});

  final bool? isLocation;

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
    final prayerTimes = (widget.isLocation ?? false)
        ? ref.watch(
            getPrayerTimesWithLocation(
              date ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
            ),
          )
        : ref.watch(
            getPrayerTimesWithSelection(
              date ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
            ),
          );
    return Scaffold(
      drawer: const Drawer(
        child: Column(),
      ),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.location_on),
        ),
        title: prayerTimes.when(
          data: (i) {
            return Column(
              children: [
                Text(i?.place?.city ?? ''),
                Text(i?.times?.keys.first ?? ''),
              ],
            );
          },
          error: (error, stacktrace) {
            return Text(error.toString());
          },
          loading: CircularProgressIndicator.new,
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
            } else {
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
                  int timeToMinutes(String time) {
                    final parts = time.split(':');
                    final hours = int.parse(parts[0]);
                    final minutes = int.parse(parts[1]);
                    return hours * 60 + minutes;
                  }

                  final prayerTimesByDay =
                      times?.times?.values.map((e) => e).toList();

                  final sunrise =
                      timeToMinutes(prayerTimesByDay?[0][1] ?? ''); // sunrise
                  final maghrib =
                      timeToMinutes(prayerTimesByDay?[0][4] ?? ''); // Maghrib
                  final nextDaySunrise = timeToMinutes(
                    prayerTimesByDay?[1][1] ?? '',
                  ); // next day sunrise

                  // final currentTime = timeToMinutes(
                  //   DateFormat('HH:mm').format(DateTime.now()),
                  // );

                  ref.watch(currentTimeProvider)._startTimer();

                  final time = ref.watch(currentTimeProvider)._time =
                      timeToMinutes(DateFormat('HH:mm').format(DateTime.now()));

                  return Column(
                    children: [
                      if (pageIndex == 0)
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.2,
                          child: NextPrayerTimeCard(
                            times: prayerTimesByDay ?? [],
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
                                final currentIndex = ref
                                    .read(
                                      findRemainingTimeProvider(
                                        prayerTimesByDay ?? [],
                                      ).notifier,
                                    )
                                    .lowestNegativeIndex;
                                return PrayerTimeCard(
                                  currentIndex: currentIndex,
                                  times: prayerTimesByDay ?? [],
                                  index: index,
                                );
                              },
                            ),
                          ),
                          if (time < maghrib && pageIndex == 0)
                            Padding(
                              padding: const EdgeInsets.all(2),
                              child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * .65,
                                child: RotatedBox(
                                  quarterTurns: 1,
                                  child: SliderTheme(
                                    data: SliderThemeData(
                                      trackHeight: 20,
                                      thumbShape:
                                          SunThumbShape(image: _sunImage),
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
                                ? Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .65,
                                      child: RotatedBox(
                                        quarterTurns: 1,
                                        child: SliderTheme(
                                          data: SliderThemeData(
                                            trackHeight: 20,
                                            thumbShape: MoonThumbShape(
                                              image: _moonImage,
                                            ),
                                          ),
                                          child: Slider(
                                            max: 1440 -
                                                maghrib +
                                                nextDaySunrise.toDouble(),
                                            value: time - maghrib.toDouble(),
                                            onChanged: null,
                                            divisions:
                                                1440 - maghrib + nextDaySunrise,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : const Text(''),
                        ],
                      ),
                    ],
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class PrayerTimeCard extends StatelessWidget {
  const PrayerTimeCard({
    required this.times,
    required this.index,
    this.currentIndex,
    super.key,
  });

  final List<List<String>>? times;
  final int index;
  final int? currentIndex;

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
      color: currentIndex == index
          ? Theme.of(context).colorScheme.secondary
          : Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ListTile(
          leading: const Icon(Icons.access_time),
          title: Center(
            child: times1(),
          ),
          trailing: Text(
            times?[0][index] ?? '',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
    );
  }
}

class FindRemainingTimeNotifier extends StateNotifier<List<List<String>>> {
  FindRemainingTimeNotifier(super.state);
  Duration nextTime = const Duration();

  int? lowestNegativeIndex = -1;
  Duration? lowestNegativeDuration;

  void checkTimes() {
    final currentTime = DateFormat('HH:mm').format(DateTime.now());
    final durationNow = Duration(
      hours: int.parse(currentTime.split(':')[0]),
      minutes: int.parse(currentTime.split(':')[1]),
    );

    for (var i = 0; i < 6; i++) {
      final durations = Duration(
        hours: int.parse(state[0][i].split(':')[0]),
        minutes: int.parse(state[0][i].split(':')[1]),
      );

      final difference = durations - durationNow;

      if (difference.isNegative) {
        if (lowestNegativeDuration == null ||
            difference <
                (lowestNegativeDuration ?? const Duration(seconds: 10))) {
          lowestNegativeDuration = difference;
          lowestNegativeIndex = i;
        }
      }
    }

    if (lowestNegativeIndex != -1) {
      // Update the index to the lowest negative duration
      print('Lowest negative duration found at index: $lowestNegativeIndex');
    } else {
      print('No negative durations found.');
    }

    // void checkTimes() {
    //   // get current time and format as hh:mm
    //   final currentTime = DateFormat('HH:mm').format(DateTime.now());
    //   final durationNow = Duration(
    //     hours: int.parse(currentTime.split(':')[0]),
    //     minutes: int.parse(currentTime.split(':')[1]),
    //   );

    //   for (var i = 0; i < (state.length); i++) {
    //     final durations = Duration(
    //       hours: int.parse(
    //         state[0][i].split(':')[0],
    //       ),
    //       minutes: int.parse(
    //         state[0][i].split(':')[1],
    //       ),
    //     );

    //     final difference = durations - durationNow;
    //     nextTime = difference;

    //     if (difference.isNegative) {
    //       final nextDayDurations = Duration(
    //         hours: int.parse(
    //           state[1][0].split(':')[0],
    //         ),
    //         minutes: int.parse(
    //           state[1][0].split(':')[1],
    //         ),
    //       );

    //       final dif = nextDayDurations - durationNow;
    //       nextTime = dif;
    //     } else {
    //       nextTime = difference;
    //     }
    //   }
  }
}

final findRemainingTimeProvider = StateNotifierProvider.family(
  (ref, List<List<String>> times) => FindRemainingTimeNotifier(
    times,
  ),
);

class NextPrayerTimeCard extends ConsumerStatefulWidget {
  const NextPrayerTimeCard({
    required this.times,
    required this.index,
    super.key,
  });

  final List<List<String>> times;
  final int index;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NextPrayerTimeCardState();
}

class _NextPrayerTimeCardState extends ConsumerState<NextPrayerTimeCard>
    with TickerProviderStateMixin {
  Timer? _timer;
  Duration? nextTime;
  AnimationController? _controller;

  void checkTimes() {
    // get current time and format as hh:mm
    final currentTime = DateFormat('HH:mm').format(DateTime.now());
    final durationNow = Duration(
      hours: int.parse(currentTime.split(':')[0]),
      minutes: int.parse(currentTime.split(':')[1]),
    );

    for (var i = 0; i < 6; i++) {
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
        nextTime = difference;
      }
      nextTime = difference;
    }
    nextTime ??= const Duration(seconds: 10);
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
    // checkTimes();
    ref.read(findRemainingTimeProvider(widget.times).notifier).checkTimes();
    getRemainingTime(
      ref.read(findRemainingTimeProvider(widget.times).notifier).nextTime,
    );
    _timer =
        Timer.periodic(nextTime ?? const Duration(seconds: 10), (Timer timer) {
      setState(() {});
    });
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        seconds: getRemainingTime(
          nextTime ??
              ref
                  .read(findRemainingTimeProvider(widget.times).notifier)
                  .nextTime,
        ),
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
              begin: getRemainingTime(nextTime ?? const Duration(seconds: 10)),
              end: 0,
            ).animate(
              _controller ??
                  AnimationController(
                    vsync: this,
                    duration: const Duration(
                      seconds: 10,
                    ),
                  ),
            ),
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
    final clockTimer = Duration(seconds: animation?.value ?? 10);

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
