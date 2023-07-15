import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:namaz_vakti/screens/home/view/home_screen.dart';
import 'package:namaz_vakti/screens/location/location_selection.dart';
import 'package:namaz_vakti/providers/location_providers.dart';
import 'package:namaz_vakti/screens/selection/selection_screen.dart';
import 'package:permission_handler/permission_handler.dart';

mixin SelectionScreenMixin on ConsumerState<SelectionScreenView> {
  Future<void> navigateToLocationSelection() async {
    await ref.read(locatorProvider.notifier).changeLocationStatus();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const LocationSelectionScreen(),
      ),
    );
  }

  Future<void> getPrayerTimesWithLocationFunction() async {
    final status = await Geolocator.requestPermission();
    switch (status) {
      case LocationPermission.denied || LocationPermission.unableToDetermine:
        await showLocationErrorDialog();
      case LocationPermission.always || LocationPermission.whileInUse:
        final location = await Geolocator.getCurrentPosition();
        await ref.read(locatorProvider.notifier).updatePosition(location);
        await ref
            .read(locatorProvider.notifier)
            .changeLocationStatus(value: true);
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => const HomeScreen(),
          ),
        );
      case LocationPermission.deniedForever:
        await openAppSettings();
    }
  }

  Future<void> showLocationErrorDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Error'),
        content: const Text(
          'Please enable location services to continue',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
