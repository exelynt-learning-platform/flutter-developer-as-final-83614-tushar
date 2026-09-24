import 'package:dartz/dartz.dart';
import 'package:employee_management/domain/core/error/exceptions.dart';
import 'package:employee_management/infrastructure/employee/data_source/employee_local.dart';
import 'package:employee_management/infrastructure/employee/data_source/employee_remote.dart';
import 'package:employee_management/infrastructure/employee/dtos/employee_dto.dart';
import 'package:employee_management/infrastructure/employee/repository/employee_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockEmployeeRemoteDataSource extends Mock
    implements EmployeeRemoteDataSource {}

class MockEmployeeLocalDataSource extends Mock
    implements EmployeeLocalDataSource {}

void main() {
  late MockEmployeeRemoteDataSource mockRemote;
  late MockEmployeeLocalDataSource mockLocal;
  late EmployeeRepository repository;

  const testDto = EmployeeDto(
    id: '1',
    name: 'John',
    email: 'john@test.com',
    emailId: '',
    avatar: '',
    mobile: '1234567890',
    country: 'India',
    state: 'MH',
    district: 'Pune',
    createdAt: '',
  );

  setUpAll(() {
    registerFallbackValue(testDto);
    registerFallbackValue(<EmployeeDto>[testDto]);
  });

  setUp(() {
    mockRemote = MockEmployeeRemoteDataSource();
    mockLocal = MockEmployeeLocalDataSource();
    repository = EmployeeRepository(
      remoteDataSource: mockRemote,
      localDataSource: mockLocal,
    );
  });

  group('EmployeeRepository', () {
    group('getEmployees', () {
      test('returns employees from remote and caches', () async {
        when(() => mockRemote.getEmployees())
            .thenAnswer((_) async => [testDto]);
        when(() => mockLocal.cacheEmployees(any()))
            .thenAnswer((_) async {});

        final result = await repository.getEmployees();

        expect(result.isRight(), true);
        result.fold(
          (_) => fail('Expected right'),
          (employees) {
            expect(employees.length, 1);
            expect(employees.first.name, 'John');
          },
        );
        verify(() => mockLocal.cacheEmployees(any())).called(1);
      });

      test('returns cached data when remote fails', () async {
        when(() => mockRemote.getEmployees())
            .thenThrow(NetworkException(message: 'No internet'));
        when(() => mockLocal.getCachedEmployees()).thenReturn([testDto]);

        final result = await repository.getEmployees();

        expect(result.isRight(), true);
        expect(repository.isOffline, true);
      });

      test('returns failure when both remote and cache fail', () async {
        when(() => mockRemote.getEmployees())
            .thenThrow(NetworkException(message: 'No internet'));
        when(() => mockLocal.getCachedEmployees())
            .thenThrow(CacheException(message: 'No cache'));

        final result = await repository.getEmployees();

        expect(result.isLeft(), true);
      });
    });

    group('getEmployeeById', () {
      test('returns employee on success', () async {
        when(() => mockRemote.getEmployeeById(id: any(named: 'id')))
            .thenAnswer((_) async => testDto);

        final result = await repository.getEmployeeById(id: '1');

        expect(result.isRight(), true);
      });

      test('returns failure on error', () async {
        when(() => mockRemote.getEmployeeById(id: any(named: 'id')))
            .thenThrow(ServerException(message: 'Not found'));

        final result = await repository.getEmployeeById(id: '999');

        expect(result.isLeft(), true);
      });
    });

    group('createEmployee', () {
      test('returns created employee on success', () async {
        when(() => mockRemote.createEmployee(dto: any(named: 'dto')))
            .thenAnswer((_) async => testDto);

        final result = await repository.createEmployee(
          employee: testDto.toEntity(),
        );

        expect(result.isRight(), true);
      });
    });

    group('updateEmployee', () {
      test('returns updated employee on success', () async {
        when(() => mockRemote.updateEmployee(dto: any(named: 'dto')))
            .thenAnswer((_) async => testDto);

        final result = await repository.updateEmployee(
          employee: testDto.toEntity(),
        );

        expect(result.isRight(), true);
      });
    });

    group('deleteEmployee', () {
      test('returns unit on success', () async {
        when(() => mockRemote.deleteEmployee(id: any(named: 'id')))
            .thenAnswer((_) async {});

        final result = await repository.deleteEmployee(id: '1');

        expect(result, const Right(unit));
      });
    });

    group('getCountries', () {
      test('returns failure on error', () async {
        when(() => mockRemote.getCountries())
            .thenThrow(ServerException(message: 'Error'));

        final result = await repository.getCountries();

        expect(result.isLeft(), true);
      });
    });
  });
}
