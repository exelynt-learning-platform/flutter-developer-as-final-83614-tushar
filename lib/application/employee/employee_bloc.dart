import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:employee_management/domain/core/error/failures.dart';
import 'package:employee_management/domain/employee/entities/country.dart';
import 'package:employee_management/domain/employee/entities/employee.dart';
import 'package:employee_management/domain/employee/repository/i_employee_repository.dart';
import 'package:employee_management/infrastructure/employee/repository/employee_repository.dart';

part 'employee_event.dart';
part 'employee_state.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final IEmployeeRepository repository;

  EmployeeBloc({required this.repository}) : super(const EmployeeState()) {
    on<LoadEmployees>(_onLoadEmployees);
    on<RefreshEmployees>(_onRefreshEmployees);
    on<SearchEmployeeById>(_onSearchEmployeeById);
    on<FilterEmployees>(_onFilterEmployees);
    on<ClearFilter>(_onClearFilter);
    on<LoadCountries>(_onLoadCountries);
    on<CreateEmployee>(_onCreateEmployee);
    on<UpdateEmployee>(_onUpdateEmployee);
    on<DeleteEmployee>(_onDeleteEmployee);
  }

  Future<void> _onLoadEmployees(
    LoadEmployees event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, failure: null, operationSuccess: null));
    final result = await repository.getEmployees();
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, failure: failure)),
      (employees) {
        final isOffline = repository is EmployeeRepository
            ? (repository as EmployeeRepository).isOffline
            : false;
        emit(state.copyWith(
          isLoading: false,
          employees: employees,
          searchId: '',
          filterName: '',
          filterEmail: '',
          filterMobile: '',
          filterCountry: '',
          filteredEmployees: employees,
          isOffline: isOffline,
          failure: null,
        ));
      },
    );
  }

  Future<void> _onRefreshEmployees(
    RefreshEmployees event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, failure: null));
    final result = await repository.getEmployees();
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, failure: failure)),
      (employees) {
        final isOffline = repository is EmployeeRepository
            ? (repository as EmployeeRepository).isOffline
            : false;
        emit(state.copyWith(
          isLoading: false,
          employees: employees,
          searchId: '',
          filterName: '',
          filterEmail: '',
          filterMobile: '',
          filterCountry: '',
          filteredEmployees: employees,
          isOffline: isOffline,
          failure: null,
        ));
      },
    );
  }

  Future<void> _onSearchEmployeeById(
    SearchEmployeeById event,
    Emitter<EmployeeState> emit,
  ) async {
    final query = event.id.trim();
    if (query.isEmpty) {
      final newState = state.copyWith(
        searchId: '',
        selectedEmployee: null,
        failure: null,
      );
      emit(newState.copyWith(
        filteredEmployees: _applyFilters(state.employees, newState),
      ));
      return;
    }

    emit(state.copyWith(isLoading: true, searchId: query, failure: null));
    final result = await repository.getEmployeeById(id: query);
    result.fold(
      (failure) {
        final localMatches =
            _applyFilters(state.employees, state.copyWith(searchId: query));
        emit(state.copyWith(
          isLoading: false,
          filteredEmployees: localMatches,
          selectedEmployee: localMatches.isNotEmpty ? localMatches.first : null,
          failure: localMatches.isEmpty ? failure : null,
        ));
      },
      (employee) => emit(state.copyWith(
        isLoading: false,
        selectedEmployee: employee,
        filteredEmployees: [employee],
        failure: null,
      )),
    );
  }

  void _onFilterEmployees(FilterEmployees event, Emitter<EmployeeState> emit) {
    final newState = state.copyWith(
      filterName: event.name ?? '',
      filterEmail: event.email ?? '',
      filterMobile: event.mobile ?? '',
      filterCountry: event.country ?? '',
    );
    emit(newState.copyWith(
      filteredEmployees: _applyFilters(state.employees, newState),
    ));
  }

  void _onClearFilter(ClearFilter event, Emitter<EmployeeState> emit) {
    final newState = state.copyWith(
      filterName: '',
      filterEmail: '',
      filterMobile: '',
      filterCountry: '',
    );
    emit(newState.copyWith(
      filteredEmployees: _applyFilters(state.employees, newState),
    ));
  }

  Future<void> _onLoadCountries(
    LoadCountries event,
    Emitter<EmployeeState> emit,
  ) async {
    final result = await repository.getCountries();
    result.fold(
      (failure) => emit(state.copyWith(failure: failure)),
      (countries) => emit(state.copyWith(countries: countries)),
    );
  }

  Future<void> _onCreateEmployee(
    CreateEmployee event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, failure: null, operationSuccess: null));
    final result = await repository.createEmployee(employee: event.employee);
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, failure: failure)),
      (employee) {
        final updated = [employee, ...state.employees];
        emit(state.copyWith(
          isLoading: false,
          employees: updated,
          searchId: '',
          filterName: '',
          filterEmail: '',
          filterMobile: '',
          filterCountry: '',
          filteredEmployees: updated,
          operationSuccess: 'Employee created successfully',
          failure: null,
        ));
      },
    );
  }

  Future<void> _onUpdateEmployee(
    UpdateEmployee event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, failure: null, operationSuccess: null));
    final result = await repository.updateEmployee(employee: event.employee);
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, failure: failure)),
      (employee) {
        final updated = state.employees
            .map((e) => e.id == employee.id ? employee : e)
            .toList();
        emit(state.copyWith(
          isLoading: false,
          employees: updated,
          selectedEmployee: employee,
          searchId: '',
          filterName: '',
          filterEmail: '',
          filterMobile: '',
          filterCountry: '',
          filteredEmployees: updated,
          operationSuccess: 'Employee updated successfully',
          failure: null,
        ));
      },
    );
  }

  Future<void> _onDeleteEmployee(
    DeleteEmployee event,
    Emitter<EmployeeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, failure: null, operationSuccess: null));
    final result = await repository.deleteEmployee(id: event.id);
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, failure: failure)),
      (_) {
        final updated =
            state.employees.where((e) => e.id != event.id).toList();
        emit(state.copyWith(
          isLoading: false,
          employees: updated,
          searchId: '',
          filterName: '',
          filterEmail: '',
          filterMobile: '',
          filterCountry: '',
          filteredEmployees: updated,
          operationSuccess: 'Employee deleted successfully',
          failure: null,
        ));
      },
    );
  }

  List<Employee> _applyFilters(List<Employee> employees, EmployeeState st) {
    var result = employees;
    if (st.searchId.isNotEmpty) {
      final query = st.searchId.toLowerCase();
      result = result
          .where((e) =>
              e.id.toLowerCase().contains(query) ||
              e.name.toLowerCase().contains(query) ||
              e.email.toLowerCase().contains(query) ||
              e.mobile.contains(query) ||
              e.country.toLowerCase().contains(query))
          .toList();
    }
    if (st.filterName.isNotEmpty) {
      result = result
          .where((e) =>
              e.name.toLowerCase().contains(st.filterName.toLowerCase()))
          .toList();
    }
    if (st.filterEmail.isNotEmpty) {
      result = result
          .where((e) =>
              e.email.toLowerCase().contains(st.filterEmail.toLowerCase()))
          .toList();
    }
    if (st.filterMobile.isNotEmpty) {
      result = result
          .where((e) => e.mobile.contains(st.filterMobile))
          .toList();
    }
    if (st.filterCountry.isNotEmpty) {
      result = result
          .where((e) =>
              e.country.toLowerCase().contains(st.filterCountry.toLowerCase()))
          .toList();
    }
    return result;
  }
}
