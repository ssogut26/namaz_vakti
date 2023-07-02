import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namaz_vakti/screens/home/view/home_screen.dart';
import 'package:namaz_vakti/utils/time_utils.dart';

final class MoonSlider extends ConsumerStatefulWidget {
  const MoonSlider({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MoonSliderState();
}

class _MoonSliderState extends ConsumerState<MoonSlider> {
  ui.Image? _moonImage;

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
    loadMoonImage();
  }

  @override
  Widget build(BuildContext context) {
    final prayerTimes = ref.read(prayerTimesProvider.notifier).prayerTimes;
    final maghrib = timeToMinutes(prayerTimes?[0][4] ?? ''); // Maghrib
    final nextDaySunrise = timeToMinutes(
      prayerTimes?[1][1] ?? '',
    ); // next day sunrise
    final time = ref.watch(currentTimeProvider.notifier).currentTime;
    return Padding(
      padding: const EdgeInsets.all(2),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .65,
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
              max: 1440 - maghrib + nextDaySunrise.toDouble(),
              value: time - maghrib.toDouble(),
              onChanged: null,
              divisions: 1440 - maghrib + nextDaySunrise,
            ),
          ),
        ),
      ),
    );
  }
}

final class MoonThumbShape extends SliderComponentShape {
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
