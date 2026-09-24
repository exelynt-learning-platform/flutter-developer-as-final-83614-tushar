import 'package:equatable/equatable.dart';

class Employee extends Equatable {
  final String id;
  final String name;
  final String email;
  final String emailId;
  final String avatar;
  final String mobile;
  final String country;
  final String state;
  final String district;
  final String createdAt;

  const Employee({
    required this.id,
    required this.name,
    required this.email,
    this.emailId = '',
    this.avatar = '',
    required this.mobile,
    required this.country,
    required this.state,
    required this.district,
    this.createdAt = '',
  });

  Employee copyWith({
    String? id,
    String? name,
    String? email,
    String? emailId,
    String? avatar,
    String? mobile,
    String? country,
    String? state,
    String? district,
    String? createdAt,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      emailId: emailId ?? this.emailId,
      avatar: avatar ?? this.avatar,
      mobile: mobile ?? this.mobile,
      country: country ?? this.country,
      state: state ?? this.state,
      district: district ?? this.district,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static const empty = Employee(
    id: '',
    name: '',
    email: '',
    mobile: '',
    country: '',
    state: '',
    district: '',
  );

  bool get isEmpty => this == empty;
  bool get isNotEmpty => !isEmpty;

  @override
  List<Object?> get props => [
        id, name, email, emailId, avatar,
        mobile, country, state, district, createdAt,
      ];
}
