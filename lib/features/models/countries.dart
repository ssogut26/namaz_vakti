import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'countries.g.dart';

@JsonSerializable()
class CountriesModel with EquatableMixin {
  CountriesModel({
    this.code,
    this.name,
  });

  factory CountriesModel.fromJson(Map<String, dynamic> json) =>
      _$CountriesModelFromJson(json);
  String? code;
  String? name;

  Map<String, dynamic> toJson() => _$CountriesModelToJson(this);

  @override
  List<Object?> get props => [code, name];

  CountriesModel copyWith({
    String? code,
    String? name,
  }) {
    return CountriesModel(
      code: code ?? this.code,
      name: name ?? this.name,
    );
  }
}
