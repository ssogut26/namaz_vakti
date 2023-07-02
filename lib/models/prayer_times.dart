import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'prayer_times.g.dart';

@JsonSerializable()

/// General prayer times model
final class PrayerTimesModel extends Equatable {
  /// Define prayer times elements
  const PrayerTimesModel({
    this.place,
    this.times,
  });

  /// Convert json to object
  factory PrayerTimesModel.fromJson(Map<String, dynamic> json) =>
      _$PrayerTimesModelFromJson(json);

  /// Convert object to json
  Map<String, dynamic> toJson() => _$PrayerTimesModelToJson(this);

  /// Prayer times place
  final Place? place;

  /// Prayer times
  final Map<String, List<String>>? times;

  /// Generate copy with method
  PrayerTimesModel copyWith({
    Place? place,
    Map<String, List<String>>? times,
  }) =>
      PrayerTimesModel(
        place: place ?? this.place,
        times: times ?? this.times,
      );
  @override
  List<Object?> get props => [place, times];
}

@JsonSerializable()

/// Get place details
final class Place extends Equatable {
  /// Define place elements
  const Place({
    this.country,
    this.countryCode,
    this.city,
    this.region,
    this.latitude,
    this.longitude,
  });

  /// Convert json to object
  factory Place.fromJson(Map<String, dynamic> json) => _$PlaceFromJson(json);

  /// Place Country
  final String? country;

  /// Place Country Code
  final String? countryCode;

  /// Place City
  final String? city;

  /// Place Region
  final String? region;
  final double? latitude;

  /// Place Longitude
  final double? longitude;

  /// Generate copy with method
  Place copyWith({
    String? country,
    String? countryCode,
    String? city,
    String? region,
    double? latitude,
    double? longitude,
  }) =>
      Place(
        country: country ?? this.country,
        countryCode: countryCode ?? this.countryCode,
        city: city ?? this.city,
        region: region ?? this.region,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
      );

  /// Convert object to json
  Map<String, dynamic> toJson() => _$PlaceToJson(this);

  @override
  List<Object?> get props => [
        country,
        countryCode,
        city,
        region,
        latitude,
        longitude,
      ];
}
