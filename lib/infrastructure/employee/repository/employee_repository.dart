import 'package:dartz/dartz.dart';
import 'package:employee_management/domain/core/error/failure_handler.dart';
import 'package:employee_management/domain/core/error/failures.dart';
import 'package:employee_management/domain/employee/entities/country.dart';
import 'package:employee_management/domain/employee/entities/employee.dart';
import 'package:employee_management/domain/employee/repository/i_employee_repository.dart';
import 'package:employee_management/infrastructure/employee/data_source/employee_local.dart';
import 'package:employee_management/infrastructure/employee/data_source/employee_remote.dart';
import 'package:employee_management/infrastructure/employee/dtos/employee_dto.dart';

class EmployeeRepository implements IEmployeeRepository {
  final EmployeeRemoteDataSource remoteDataSource;
  final EmployeeLocalDataSource localDataSource;

  bool _isOffline = false;
  bool get isOffline => _isOffline;

  EmployeeRepository({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<AppFailure, List<Employee>>> getEmployees() async {
    try {
      final dtos = await remoteDataSource.getEmployees();
      await localDataSource.cacheEmployees(dtos);
      _isOffline = false;
      return Right(dtos.map((dto) => dto.toEntity()).toList());
    } catch (e) {
      try {
        final cachedDtos = localDataSource.getCachedEmployees();
        _isOffline = true;
        return Right(cachedDtos.map((dto) => dto.toEntity()).toList());
      } catch (_) {
        _isOffline = false;
        return Left(FailureHandler.handleFailure(e));
      }
    }
  }

  @override
  Future<Either<AppFailure, Employee>> getEmployeeById({
    required String id,
  }) async {
    try {
      final dto = await remoteDataSource.getEmployeeById(id: id);
      return Right(dto.toEntity());
    } catch (e) {
      try {
        final cached = localDataSource.getCachedEmployees();
        final match = cached.firstWhere((e) => e.id == id);
        return Right(match.toEntity());
      } catch (_) {
        return Left(FailureHandler.handleFailure(e));
      }
    }
  }

  @override
  Future<Either<AppFailure, Employee>> createEmployee({
    required Employee employee,
  }) async {
    try {
      final dto = EmployeeDto.fromEntity(employee);
      final result = await remoteDataSource.createEmployee(dto: dto);
      try {
        final current = localDataSource.getCachedEmployees().toList();
        current.add(result);
        await localDataSource.cacheEmployees(current);
      } catch (_) {}
      return Right(result.toEntity());
    } catch (e) {
      return Left(FailureHandler.handleFailure(e));
    }
  }

  @override
  Future<Either<AppFailure, Employee>> updateEmployee({
    required Employee employee,
  }) async {
    try {
      final dto = EmployeeDto.fromEntity(employee);
      final result = await remoteDataSource.updateEmployee(dto: dto);
      try {
        final current = localDataSource.getCachedEmployees().toList();
        final idx = current.indexWhere((e) => e.id == result.id);
        if (idx != -1) {
          current[idx] = result;
          await localDataSource.cacheEmployees(current);
        }
      } catch (_) {}
      return Right(result.toEntity());
    } catch (e) {
      return Left(FailureHandler.handleFailure(e));
    }
  }

  @override
  Future<Either<AppFailure, Unit>> deleteEmployee({
    required String id,
  }) async {
    try {
      await remoteDataSource.deleteEmployee(id: id);
      try {
        final current = localDataSource.getCachedEmployees().toList();
        current.removeWhere((e) => e.id == id);
        await localDataSource.cacheEmployees(current);
      } catch (_) {}
      return const Right(unit);
    } catch (e) {
      return Left(FailureHandler.handleFailure(e));
    }
  }

  @override
  Future<Either<AppFailure, List<Country>>> getCountries() async {
    try {
      final dtos = await remoteDataSource.getCountries();
      return Right(dtos.map((dto) => dto.toEntity()).toList());
    } catch (e) {
      return Left(FailureHandler.handleFailure(e));
    }
  }
}
