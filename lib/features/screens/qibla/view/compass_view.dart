import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:namaz_vakti/constants/constants.dart';
import 'package:namaz_vakti/extensions/extensions.dart';
import 'package:namaz_vakti/generated/locale_keys.g.dart';
import 'package:namaz_vakti/product/providers/qibla_providers.dart';
import 'package:namaz_vakti/product/utils/loading.dart';

part '../widgets/compass_view_widgets.dart';

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
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                _Compass(qiblahDirection: data),
                _Needle(qiblahDirection: data),
                _Degree(qiblahDirection: data),
              ],
            ),
          );
        },
        error: (error, StackTrace e) {
          return Text(error.toString());
        },
        loading: () {
          return const LoadingWidget();
        },
      ),
    );
  }
}
