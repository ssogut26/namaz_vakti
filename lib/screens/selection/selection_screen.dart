import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namaz_vakti/extensions/extensions.dart';
import 'package:namaz_vakti/generated/locale_keys.g.dart';
import 'package:namaz_vakti/screens/location/location_selection.dart';
import 'package:namaz_vakti/screens/selection/selection_screen_mixin.dart';

class SelectionScreenView extends ConsumerStatefulWidget {
  const SelectionScreenView({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectionScreenViewState();
}

class _SelectionScreenViewState extends ConsumerState<SelectionScreenView>
    with SelectionScreenMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.50,
                  width: MediaQuery.of(context).size.width,
                  child: AppElevatedButton(
                    color: const Color(0xff374B4A),
                    onPressed: navigateToLocationSelection,
                    text: LocaleKeys.selectionScreen_enterManually.locale,
                  ),
                ),
              ),
              ClipPath(
                clipper: BottomWaveClipper(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.55,
                  child: AppElevatedButton(
                    color: const Color(0xff88D9E6),
                    onPressed: getPrayerTimesWithLocationFunction,
                    text: LocaleKeys.selectionScreen_useMyLocation.locale,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () async {
                    if (context.locale == const Locale('en', 'US')) {
                      await context.setLocale(const Locale('tr', 'TR'));
                    } else {
                      await context.setLocale(const Locale('en', 'US'));
                    }
                  },
                  icon: const Icon(
                    Icons.language,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 4,
      size.height - 80,
      size.width / 2,
      size.height - 40,
    );
    path.quadraticBezierTo(
      size.width - (size.width / 4),
      size.height,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
