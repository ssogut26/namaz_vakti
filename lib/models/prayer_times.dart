import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'prayer_times.g.dart';

@JsonSerializable()
@HiveType(typeId: 0)

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
  @HiveField(0)
  final Place? place;

  /// Prayer times
  @HiveField(1)
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
@HiveType(typeId: 1)

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
  @HiveField(0)
  final String? country;

  /// Place Country Code
  @HiveField(1)
  final String? countryCode;

  /// Place City
  @HiveField(2)
  final String? city;

  /// Place Region
  @HiveField(3)
  final String? region;
  @HiveField(4)
  final double? latitude;

  /// Place Longitude
  @HiveField(5)
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
