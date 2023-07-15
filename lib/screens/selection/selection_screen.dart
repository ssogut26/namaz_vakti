import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namaz_vakti/constants/constants.dart';
import 'package:namaz_vakti/extensions/extensions.dart';
import 'package:namaz_vakti/generated/locale_keys.g.dart';
import 'package:namaz_vakti/mixins/selection_screen_mixin.dart';
import 'package:namaz_vakti/screens/location/location_selection.dart';

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
              _SelectLocation(
                navigateToLocationSelection,
              ),
              _UseLocation(
                getPrayerTimesWithLocationFunction,
              ),
              Align(
                alignment: Alignment.topRight,
                child: Column(
                  children: [
                    IconButton(
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
                    Text(
                      context.locale.languageCode,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UseLocation extends StatelessWidget {
  const _UseLocation(
    this.getPrayerTimesWithLocationFunction,
  );

  final void Function() getPrayerTimesWithLocationFunction;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: BottomWaveClipper(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.55,
        child: AppElevatedButton(
          color: AppConstants.beachBlue,
          onPressed: getPrayerTimesWithLocationFunction,
          text: LocaleKeys.selectionScreen_useMyLocation.locale,
        ),
      ),
    );
  }
}

class _SelectLocation extends StatelessWidget {
  const _SelectLocation(
    this.navigateToLocationSelection,
  );

  final void Function() navigateToLocationSelection;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.50,
        width: MediaQuery.of(context).size.width,
        child: AppElevatedButton(
          color: AppConstants.stoneDark,
          onPressed: navigateToLocationSelection,
          text: LocaleKeys.selectionScreen_enterManually.locale,
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
