import 'package:employee_management/domain/core/constants/api_constants.dart';
import 'package:employee_management/infrastructure/core/http/http_service.dart';
import 'package:employee_management/infrastructure/employee/dtos/country_dto.dart';
import 'package:employee_management/infrastructure/employee/dtos/employee_dto.dart';

class EmployeeRemoteDataSource {
  final HttpService httpService;

  EmployeeRemoteDataSource({required this.httpService});

  Future<List<EmployeeDto>> getEmployees() async {
    final response = await httpService.get(ApiConstants.employees);
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((json) => EmployeeDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<EmployeeDto> getEmployeeById({required String id}) async {
    final response = await httpService.get(ApiConstants.employeeById(id));
    return EmployeeDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<EmployeeDto> createEmployee({required EmployeeDto dto}) async {
    final response = await httpService.post(
      ApiConstants.employees,
      data: dto.toJson(),
    );
    return EmployeeDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<EmployeeDto> updateEmployee({required EmployeeDto dto}) async {
    final response = await httpService.put(
      ApiConstants.employeeById(dto.id),
      data: dto.toJson(),
    );
    return EmployeeDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteEmployee({required String id}) async {
    await httpService.delete(ApiConstants.employeeById(id));
  }

  Future<List<CountryDto>> getCountries() async {
    final response = await httpService.get(ApiConstants.countries);
    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((json) => CountryDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
