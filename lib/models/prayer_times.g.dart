// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_times.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PrayerTimesModelAdapter extends TypeAdapter<PrayerTimesModel> {
  @override
  final int typeId = 0;

  @override
  PrayerTimesModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrayerTimesModel(
      place: fields[0] as Place?,
      times: (fields[1] as Map?)?.map((dynamic k, dynamic v) =>
          MapEntry(k as String, (v as List).cast<String>())),
    );
  }

  @override
  void write(BinaryWriter writer, PrayerTimesModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.place)
      ..writeByte(1)
      ..write(obj.times);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerTimesModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PlaceAdapter extends TypeAdapter<Place> {
  @override
  final int typeId = 1;

  @override
  Place read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Place(
      country: fields[0] as String?,
      countryCode: fields[1] as String?,
      city: fields[2] as String?,
      region: fields[3] as String?,
      latitude: fields[4] as double?,
      longitude: fields[5] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Place obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.country)
      ..writeByte(1)
      ..write(obj.countryCode)
      ..writeByte(2)
      ..write(obj.city)
      ..writeByte(3)
      ..write(obj.region)
      ..writeByte(4)
      ..write(obj.latitude)
      ..writeByte(5)
      ..write(obj.longitude);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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
