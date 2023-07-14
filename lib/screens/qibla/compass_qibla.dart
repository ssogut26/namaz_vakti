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

class QiblaCompassViewState extends ConsumerState<QiblaCompassView> {
  @override
  Widget build(BuildContext context) {
    final qiblaDirection = ref.watch(qiblaProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.findQibla_qiblaCompass.locale),
      ),
      body: qiblaDirection.when(
        data: (data) {
          final compassSvg = SvgPicture.asset(
            'assets/svg/compass.svg',
            height: 300,
            width: 300,
          );

          final needleSvg = SvgPicture.asset(
            'assets/svg/needle.svg',
            height: 300,
            width: 300,
          );
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Transform.rotate(
                  angle: data.direction * (pi / 180) * -1,
                  child: compassSvg,
                ),
                Transform.rotate(
                  angle: data.qiblah * (pi / 180) * -1,
                  child: needleSvg,
                ),
                Positioned(
                  bottom: 8,
                  child: Text('${data.offset.toStringAsFixed(3)}°'),
                )
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
