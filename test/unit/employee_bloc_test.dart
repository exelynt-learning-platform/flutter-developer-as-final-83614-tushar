import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:employee_management/application/employee/employee_bloc.dart';
import 'package:employee_management/domain/core/error/failures.dart';
import 'package:employee_management/domain/employee/entities/country.dart';
import 'package:employee_management/domain/employee/entities/employee.dart';
import 'package:employee_management/domain/employee/repository/i_employee_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockEmployeeRepository extends Mock implements IEmployeeRepository {}

void main() {
  late MockEmployeeRepository mockRepository;
  late EmployeeBloc employeeBloc;

  const testEmployee = Employee(
    id: '1',
    name: 'John Doe',
    email: 'john@test.com',
    mobile: '1234567890',
    country: 'India',
    state: 'Maharashtra',
    district: 'Pune',
  );

  const testEmployee2 = Employee(
    id: '2',
    name: 'Jane Smith',
    email: 'jane@test.com',
    mobile: '0987654321',
    country: 'USA',
    state: 'California',
    district: 'LA',
  );

  const testCountry = Country(id: '1', country: 'India');

  setUpAll(() {
    registerFallbackValue(testEmployee);
  });

  setUp(() {
    mockRepository = MockEmployeeRepository();
    employeeBloc = EmployeeBloc(repository: mockRepository);
  });

  tearDown(() {
    employeeBloc.close();
  });

  group('EmployeeBloc', () {
    test('initial state is EmployeeState', () {
      expect(employeeBloc.state, const EmployeeState());
    });

    blocTest<EmployeeBloc, EmployeeState>(
      'emits loaded state on successful LoadEmployees',
      build: () {
        when(() => mockRepository.getEmployees())
            .thenAnswer((_) async => const Right([testEmployee, testEmployee2]));
        return employeeBloc;
      },
      act: (bloc) => bloc.add(const LoadEmployees()),
      expect: () => [
        const EmployeeState(isLoading: true),
        const EmployeeState(
          employees: [testEmployee, testEmployee2],
          filteredEmployees: [testEmployee, testEmployee2],
        ),
      ],
    );

    blocTest<EmployeeBloc, EmployeeState>(
      'emits failure state on LoadEmployees error',
      build: () {
        when(() => mockRepository.getEmployees())
            .thenAnswer((_) async => const Left(ServerFailure('Server error')));
        return employeeBloc;
      },
      act: (bloc) => bloc.add(const LoadEmployees()),
      expect: () => [
        const EmployeeState(isLoading: true),
        const EmployeeState(failure: ServerFailure('Server error')),
      ],
    );

    blocTest<EmployeeBloc, EmployeeState>(
      'filters employees by name',
      build: () => employeeBloc,
      seed: () => const EmployeeState(
        employees: [testEmployee, testEmployee2],
        filteredEmployees: [testEmployee, testEmployee2],
      ),
      act: (bloc) => bloc.add(const FilterEmployees(name: 'John')),
      expect: () => [
        const EmployeeState(
          employees: [testEmployee, testEmployee2],
          filteredEmployees: [testEmployee],
          filterName: 'John',
        ),
      ],
    );

    blocTest<EmployeeBloc, EmployeeState>(
      'filters employees by country',
      build: () => employeeBloc,
      seed: () => const EmployeeState(
        employees: [testEmployee, testEmployee2],
        filteredEmployees: [testEmployee, testEmployee2],
      ),
      act: (bloc) => bloc.add(const FilterEmployees(country: 'India')),
      expect: () => [
        const EmployeeState(
          employees: [testEmployee, testEmployee2],
          filteredEmployees: [testEmployee],
          filterCountry: 'India',
        ),
      ],
    );

    blocTest<EmployeeBloc, EmployeeState>(
      'clears all filters',
      build: () => employeeBloc,
      seed: () => const EmployeeState(
        employees: [testEmployee, testEmployee2],
        filteredEmployees: [testEmployee],
        filterName: 'John',
      ),
      act: (bloc) => bloc.add(const ClearFilter()),
      expect: () => [
        const EmployeeState(
          employees: [testEmployee, testEmployee2],
          filteredEmployees: [testEmployee, testEmployee2],
        ),
      ],
    );

    blocTest<EmployeeBloc, EmployeeState>(
      'emits success on CreateEmployee',
      build: () {
        when(() => mockRepository.createEmployee(employee: any(named: 'employee')))
            .thenAnswer((_) async => const Right(testEmployee));
        return employeeBloc;
      },
      act: (bloc) => bloc.add(const CreateEmployee(employee: testEmployee)),
      expect: () => [
        const EmployeeState(isLoading: true),
        const EmployeeState(
          employees: [testEmployee],
          filteredEmployees: [testEmployee],
          operationSuccess: 'Employee created successfully',
        ),
      ],
    );

    blocTest<EmployeeBloc, EmployeeState>(
      'emits success on DeleteEmployee',
      build: () {
        when(() => mockRepository.deleteEmployee(id: any(named: 'id')))
            .thenAnswer((_) async => const Right(unit));
        return employeeBloc;
      },
      seed: () => const EmployeeState(
        employees: [testEmployee, testEmployee2],
        filteredEmployees: [testEmployee, testEmployee2],
      ),
      act: (bloc) => bloc.add(const DeleteEmployee(id: '1')),
      expect: () => [
        const EmployeeState(
          isLoading: true,
          employees: [testEmployee, testEmployee2],
          filteredEmployees: [testEmployee, testEmployee2],
        ),
        const EmployeeState(
          employees: [testEmployee2],
          filteredEmployees: [testEmployee2],
          operationSuccess: 'Employee deleted successfully',
        ),
      ],
    );

    blocTest<EmployeeBloc, EmployeeState>(
      'loads countries successfully',
      build: () {
        when(() => mockRepository.getCountries())
            .thenAnswer((_) async => const Right([testCountry]));
        return employeeBloc;
      },
      act: (bloc) => bloc.add(const LoadCountries()),
      expect: () => [
        const EmployeeState(countries: [testCountry]),
      ],
    );

    blocTest<EmployeeBloc, EmployeeState>(
      'searches employee by id',
      build: () {
        when(() => mockRepository.getEmployeeById(id: any(named: 'id')))
            .thenAnswer((_) async => const Right(testEmployee));
        return employeeBloc;
      },
      act: (bloc) => bloc.add(const SearchEmployeeById(id: '1')),
      expect: () => [
        const EmployeeState(isLoading: true, searchId: '1'),
        const EmployeeState(
          searchId: '1',
          selectedEmployee: testEmployee,
          filteredEmployees: [testEmployee],
        ),
      ],
    );

    blocTest<EmployeeBloc, EmployeeState>(
      'emits success on UpdateEmployee',
      build: () {
        final updated = testEmployee.copyWith(name: 'Updated Name');
        when(() => mockRepository.updateEmployee(employee: any(named: 'employee')))
            .thenAnswer((_) async => Right(updated));
        return employeeBloc;
      },
      seed: () => const EmployeeState(
        employees: [testEmployee],
        filteredEmployees: [testEmployee],
      ),
      act: (bloc) => bloc.add(
        UpdateEmployee(employee: testEmployee.copyWith(name: 'Updated Name')),
      ),
      expect: () {
        final updated = testEmployee.copyWith(name: 'Updated Name');
        return [
          const EmployeeState(
            isLoading: true,
            employees: [testEmployee],
            filteredEmployees: [testEmployee],
          ),
          EmployeeState(
            employees: [updated],
            selectedEmployee: updated,
            filteredEmployees: [updated],
            operationSuccess: 'Employee updated successfully',
          ),
        ];
      },
    );
  });
}
