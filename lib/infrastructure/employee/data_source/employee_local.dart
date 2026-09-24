import 'dart:convert';

import 'package:employee_management/domain/core/error/exceptions.dart';
import 'package:employee_management/infrastructure/core/local_storage/shared_prefs_service.dart';
import 'package:employee_management/infrastructure/employee/dtos/employee_dto.dart';

class EmployeeLocalDataSource {
  final SharedPrefsService sharedPrefsService;

  EmployeeLocalDataSource({required this.sharedPrefsService});

  Future<void> cacheEmployees(List<EmployeeDto> employees) async {
    final jsonList = employees.map((dto) => dto.toJson()..['id'] = dto.id).toList();
    final jsonString = jsonEncode(jsonList);
    await sharedPrefsService.cacheEmployeeList(jsonString);
  }

  List<EmployeeDto> getCachedEmployees() {
    final jsonString = sharedPrefsService.getCachedEmployeeList();
    if (jsonString == null || jsonString.isEmpty) {
      throw CacheException(message: 'No cached employee data');
    }
    final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) => EmployeeDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> clearCache() async {
    await sharedPrefsService.clearEmployeeCache();
  }
}
