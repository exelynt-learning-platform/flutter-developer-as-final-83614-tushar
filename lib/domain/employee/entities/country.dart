import 'package:equatable/equatable.dart';

class Country extends Equatable {
  final String id;
  final String country;
  final String flag;
  final String createdAt;

  const Country({
    required this.id,
    required this.country,
    this.flag = '',
    this.createdAt = '',
  });

  @override
  List<Object?> get props => [id, country, flag, createdAt];
}
