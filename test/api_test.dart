import 'package:flutter_test/flutter_test.dart';
import 'package:namaz_vakti/product/services/api.dart';

void main() {
  test('Countries Test', () async {
    final countries = await ApiService.instance.getCountries();
    expect(countries, isNotNull);
  });
  test('Cities Test', () async {
    final cities = await ApiService.instance.getCities('Ankara');
    expect(cities, isNotNull);
  });
  test(
    'Districts Test',
    () async {
      final districts =
          await ApiService.instance.getDistrict('Turkey', 'Ankara');
      expect(districts, isNotNull);
    },
  );
  test('Prayer Times Test', () async {
    final prayerTimes = await ApiService.instance
        .getPrayerTimes('Turkey', 'Eskişehir', 'Eskişehir', '2023-06-06');
    expect(prayerTimes, isNotNull);
  });

  test('PrayerTimesWithLocation Test', () async {
    final prayerTimes = await ApiService.instance.getPrayerTimesByLocation(
      latitude: '39.766219',
      longitude: '30.526714',
      date: '2023-06-06',
    );
    expect(prayerTimes, isNotNull);
  });
}
