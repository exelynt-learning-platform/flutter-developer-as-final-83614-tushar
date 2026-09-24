import 'package:employee_management/domain/employee/entities/country.dart';

class CountryDto {
  final String id;
  final String country;
  final String flag;
  final String createdAt;

  const CountryDto({
    required this.id,
    required this.country,
    required this.flag,
    required this.createdAt,
  });

  factory CountryDto.fromJson(Map<String, dynamic> json) {
    return CountryDto(
      id: json['id']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      flag: json['flag']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }

  Country toEntity() {
    return Country(
      id: id,
      country: country,
      flag: flag,
      createdAt: createdAt,
    );
  }
}
