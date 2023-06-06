// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_times.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrayerTimesModel _$PrayerTimesModelFromJson(Map<String, dynamic> json) =>
    PrayerTimesModel(
      place: json['place'] == null
          ? null
          : Place.fromJson(json['place'] as Map<String, dynamic>),
      times: (json['times'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
    );

Map<String, dynamic> _$PrayerTimesModelToJson(PrayerTimesModel instance) =>
    <String, dynamic>{
      'place': instance.place,
      'times': instance.times,
    };

Place _$PlaceFromJson(Map<String, dynamic> json) => Place(
      country: json['country'] as String?,
      countryCode: json['countryCode'] as String?,
      city: json['city'] as String?,
      region: json['region'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PlaceToJson(Place instance) => <String, dynamic>{
      'country': instance.country,
      'countryCode': instance.countryCode,
      'city': instance.city,
      'region': instance.region,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
