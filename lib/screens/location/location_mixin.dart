import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namaz_vakti/screens/location/location_selection.dart';

mixin LocationMixin on LocationSelectionScreenState {
  @override
  WidgetRef get ref;

  void updateCountry(String value) {
    final locationValues = ref.read(locationProvider.notifier);
    setState(() {
      locationValues.changeCountry(value);
      locationValues.changeCity('');
      locationValues.changeDistrict('');
    });
  }

  void updateCity(String value) {
    final locationValues = ref.read(locationProvider.notifier);
    setState(() {
      locationValues.changeCity(value);
      locationValues.changeDistrict('');
    });
  }

  void updateDistrict(String value) {
    final locationValues = ref.read(locationProvider.notifier);
    setState(() {
      locationValues.changeDistrict(value);
    });
  }
}
