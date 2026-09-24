import 'package:dartz/dartz.dart';
import 'package:employee_management/domain/core/error/failures.dart';
import 'package:employee_management/domain/employee/entities/country.dart';
import 'package:employee_management/domain/employee/entities/employee.dart';

abstract class IEmployeeRepository {
  Future<Either<AppFailure, List<Employee>>> getEmployees();
  Future<Either<AppFailure, Employee>> getEmployeeById({required String id});
  Future<Either<AppFailure, Employee>> createEmployee({required Employee employee});
  Future<Either<AppFailure, Employee>> updateEmployee({required Employee employee});
  Future<Either<AppFailure, Unit>> deleteEmployee({required String id});
  Future<Either<AppFailure, List<Country>>> getCountries();
}
