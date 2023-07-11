import 'package:equatable/equatable.dart';

final class LocationModel extends Equatable {
  const LocationModel({
    this.country,
    this.city,
    this.district,
    this.latitude,
    this.longitude,
  });

  final String? country;
  final String? city;
  final String? district;
  final String? latitude;
  final String? longitude;

  LocationModel copyWith({
    String? country,
    String? city,
    String? district,
    String? latitude,
    String? longitude,
  }) {
    return LocationModel(
      country: country ?? this.country,
      city: city ?? this.city,
      district: district ?? this.district,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  List<Object?> get props => [
        country,
        city,
        district,
        latitude,
        longitude,
      ];
}
