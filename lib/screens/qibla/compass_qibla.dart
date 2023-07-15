import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:namaz_vakti/extensions/extensions.dart';
import 'package:namaz_vakti/generated/locale_keys.g.dart';
import 'package:namaz_vakti/utils/loading.dart';

final qiblaProvider = StreamProvider<QiblahDirection>((ref) {
  FlutterQiblah.requestPermissions();
  FlutterQiblah.androidDeviceSensorSupport();
  return FlutterQiblah.qiblahStream;
});

class QiblaCompassView extends ConsumerStatefulWidget {
  const QiblaCompassView({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      QiblaCompassViewState();
}

class QiblaCompassViewState extends ConsumerState<QiblaCompassView>
    with TickerProviderStateMixin {
  Animation<double>? animation;
  AnimationController? _animationController;
  double begin = 0;
  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    // ignore: prefer_int_literals
    animation = Tween(begin: 0.0, end: 0.0).animate(_animationController!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final qiblaDirection = ref.watch(qiblaProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.findQibla_qiblaCompass.locale),
      ),
      body: qiblaDirection.when(
        data: (data) {
          // print()
          final compassSvg = SvgPicture.asset(
            'assets/svg/compass.svg',
            width: MediaQuery.of(context).size.width * 0.9,
          );
          final needleSvg = SvgPicture.asset(
            'assets/svg/needle.svg',
            height: 300,
          );

          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                AnimatedRotation(
                  turns: data.direction * pi / 180 - 1,
                  duration: const Duration(seconds: 1),
                  child: compassSvg,
                ),
                AnimatedRotation(
                  turns: data.qiblah * pi / 180,
                  duration: const Duration(seconds: 1),
                  child: needleSvg,
                ),
                Positioned(
                  bottom: 8,
                  child: Text(
                    '${data.direction.toStringAsFixed(2)}°',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
          );
        },
        error: (error, StackTrace) {
          return Text(error.toString());
        },
        loading: () {
          return const LoadingWidget();
        },
      ),
    );
  }
}
