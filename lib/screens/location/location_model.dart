import 'package:equatable/equatable.dart';

class LocationModel extends Equatable {
  const LocationModel(this.country, this.city, this.district);

  final String country;
  final String city;
  final String district;

  LocationModel copyWith({
    String? country,
    String? city,
    String? district,
  }) {
    return LocationModel(
      country ?? this.country,
      city ?? this.city,
      district ?? this.district,
    );
  }

  @override
  List<Object?> get props => [country, city, district];
}
