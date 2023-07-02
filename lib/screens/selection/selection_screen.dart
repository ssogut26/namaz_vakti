import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      appBar: AppBar(
        title: const Text('Selection Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AppElevatedButton(
                  onPressed: getPrayerTimesWithLocationFunction,
                  text: 'Use my location',
                ),
              ),
              AppElevatedButton(
                onPressed: navigateToLocationSelection,
                text: 'I will enter my location manually',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
