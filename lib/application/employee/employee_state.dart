part of 'employee_bloc.dart';

class EmployeeState extends Equatable {
  final bool isLoading;
  final List<Employee> employees;
  final List<Employee> filteredEmployees;
  final List<Country> countries;
  final Employee? selectedEmployee;
  final AppFailure? failure;
  final bool isOffline;
  final String searchId;
  final String filterName;
  final String filterEmail;
  final String filterMobile;
  final String filterCountry;
  final String? operationSuccess;

  const EmployeeState({
    this.isLoading = false,
    this.employees = const [],
    this.filteredEmployees = const [],
    this.countries = const [],
    this.selectedEmployee,
    this.failure,
    this.isOffline = false,
    this.searchId = '',
    this.filterName = '',
    this.filterEmail = '',
    this.filterMobile = '',
    this.filterCountry = '',
    this.operationSuccess,
  });

  EmployeeState copyWith({
    bool? isLoading,
    List<Employee>? employees,
    List<Employee>? filteredEmployees,
    List<Country>? countries,
    Employee? selectedEmployee,
    AppFailure? failure,
    bool? isOffline,
    String? searchId,
    String? filterName,
    String? filterEmail,
    String? filterMobile,
    String? filterCountry,
    String? operationSuccess,
  }) {
    return EmployeeState(
      isLoading: isLoading ?? this.isLoading,
      employees: employees ?? this.employees,
      filteredEmployees: filteredEmployees ?? this.filteredEmployees,
      countries: countries ?? this.countries,
      selectedEmployee: selectedEmployee ?? this.selectedEmployee,
      failure: failure,
      isOffline: isOffline ?? this.isOffline,
      searchId: searchId ?? this.searchId,
      filterName: filterName ?? this.filterName,
      filterEmail: filterEmail ?? this.filterEmail,
      filterMobile: filterMobile ?? this.filterMobile,
      filterCountry: filterCountry ?? this.filterCountry,
      operationSuccess: operationSuccess,
    );
  }

  bool get hasActiveFilters =>
      filterName.isNotEmpty ||
      filterEmail.isNotEmpty ||
      filterMobile.isNotEmpty ||
      filterCountry.isNotEmpty;

  @override
  List<Object?> get props => [
        isLoading, employees, filteredEmployees, countries,
        selectedEmployee, failure, isOffline, searchId,
        filterName, filterEmail, filterMobile, filterCountry,
        operationSuccess,
      ];
}
