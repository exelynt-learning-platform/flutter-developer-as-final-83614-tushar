import 'package:employee_management/domain/employee/entities/employee.dart';

class EmployeeDto {
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

  const EmployeeDto({
    required this.id,
    required this.name,
    required this.email,
    required this.emailId,
    required this.avatar,
    required this.mobile,
    required this.country,
    required this.state,
    required this.district,
    required this.createdAt,
  });

  factory EmployeeDto.fromJson(Map<String, dynamic> json) {
    return EmployeeDto(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      emailId: json['emailId']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'emailId': emailId,
      'avatar': avatar,
      'mobile': mobile,
      'country': country,
      'state': state,
      'district': district,
    };
  }

  Employee toEntity() {
    return Employee(
      id: id,
      name: name,
      email: email,
      emailId: emailId,
      avatar: avatar,
      mobile: mobile,
      country: country,
      state: state,
      district: district,
      createdAt: createdAt,
    );
  }

  factory EmployeeDto.fromEntity(Employee entity) {
    return EmployeeDto(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      emailId: entity.emailId,
      avatar: entity.avatar,
      mobile: entity.mobile,
      country: entity.country,
      state: entity.state,
      district: entity.district,
      createdAt: entity.createdAt,
    );
  }
}
