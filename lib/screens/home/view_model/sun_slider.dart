import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namaz_vakti/screens/home/view/home_screen.dart';
import 'package:namaz_vakti/utils/time_utils.dart';

class SunSlider extends ConsumerStatefulWidget {
  const SunSlider({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SunSliderState();
}

class _SunSliderState extends ConsumerState<SunSlider> {
  ui.Image? _sunImage;

  // A method to load the image asset
  Future<void> _loadSunImage() async {
    // Get the byte data of the image file
    final data = await rootBundle.load('assets/images/sun.png');
    // Decode the image data and create an image object
    final image = await decodeImageFromList(data.buffer.asUint8List());
    // Update the state with the image object
    setState(() {
      _sunImage = image;
    });
  }

  @override
  void initState() {
    super.initState();
    // Load the image when the widget is initialized
    _loadSunImage();
  }

  @override
  Widget build(BuildContext context) {
    final prayerTimes = ref.read(prayerTimesProvider.notifier).prayerTimes;
    final sunrise = timeToMinutes(prayerTimes?[0][1] ?? ''); // sunrise
    final maghrib = timeToMinutes(prayerTimes?[0][4] ?? ''); // Maghrib
    final time = ref.watch(currentTimeProvider.notifier).currentTime;
    return Padding(
      padding: const EdgeInsets.all(2),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .65,
        child: RotatedBox(
          quarterTurns: 1,
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 5,
              disabledActiveTrackColor: Colors.yellow,
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
