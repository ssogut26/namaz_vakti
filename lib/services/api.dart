import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:namaz_vakti/constants/constants.dart';
import 'package:namaz_vakti/models/countries.dart';
import 'package:namaz_vakti/models/prayer_times.dart';

/// Abstract class for api service
abstract class Api {
  /// Get countries
  Future<List<CountriesModel?>> getCountries();

  /// Get districts
  Future<List<dynamic>> getDistrict(String countryId, String cityId);

  /// Get cities
  Future<List<dynamic>> getCities(String countryId);

  /// Get prayer times
  Future<PrayerTimesModel?> getPrayerTimes(
    String countryId,
    String cityId,
    String district,
    String date, {
    String days = '1',
  });

  Future<PrayerTimesModel?> getPrayerTimesByLocation({
    required String latitude,
    required String longitude,
    required String date,
    String days = '1',
  });
}

/// Api service for namaz vakti
class ApiService extends Api {
  ApiService._();
  static final ApiService instance = ApiService._();
  @override
  Future<List<CountriesModel?>> getCountries() async {
    final request =
        await http.get(Uri.parse('${AppConstants.baseURL}countries'));
    final decodedCountryList = json.decode(request.body) as List<dynamic>;
    final countryList = List<CountriesModel>.from(
      decodedCountryList
          .map((e) => CountriesModel.fromJson(e as Map<String, dynamic>)),
    );

    return countryList;
  }

  @override
  Future<List<dynamic>> getCities(String countryId) async {
    final request = await http
        .get(Uri.parse('${AppConstants.baseURL}regions?country=$countryId'));
    final districtList = jsonDecode(request.body);
    return districtList as List<dynamic>;
  }

  @override
  Future<List<dynamic>> getDistrict(
    String countryId,
    String cityId,
  ) async {
    final request = await http.get(
      Uri.parse(
        '${AppConstants.baseURL}cities?country=$countryId&region=$cityId',
      ),
    );
    final cityList = jsonDecode(request.body);
    return cityList as List<dynamic>;
  }

  @override
  Future<PrayerTimesModel?> getPrayerTimes(
    String countryId,
    String cityId,
    String district,
    String date, {
    String days = '30',
  }) async {
    try {
      final request = await http.get(
        Uri.parse(
          '${AppConstants.baseURL}/timesFromPlace?country=$countryId&region=$cityId&city=$district&date=$date&days=$days&timezoneOffset=180',
        ),
      );
      final prayerTimes = PrayerTimesModel.fromJson(
        json.decode(request.body) as Map<String, dynamic>,
      );
      return prayerTimes;
    } catch (e) {
      print(e);
    }
    return null;
  }

  @override
  Future<PrayerTimesModel?> getPrayerTimesByLocation({
    required String latitude,
    required String longitude,
    required String date,
    String days = '30',
  }) async {
    final request = await http.get(
      Uri.parse(
        '${AppConstants.baseURL}/timesFromCoordinates?lat=$latitude&lng=$longitude&date=$date&days=$days&timezoneOffset=180',
      ),
    );
    final prayerTimes = PrayerTimesModel.fromJson(
      json.decode(request.body) as Map<String, dynamic>,
    );
    return prayerTimes;
  }
}
