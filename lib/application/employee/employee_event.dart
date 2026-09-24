part of 'employee_bloc.dart';

abstract class EmployeeEvent extends Equatable {
  const EmployeeEvent();

  @override
  List<Object?> get props => [];
}

class LoadEmployees extends EmployeeEvent {
  const LoadEmployees();
}

class RefreshEmployees extends EmployeeEvent {
  const RefreshEmployees();
}

class SearchEmployeeById extends EmployeeEvent {
  final String id;

  const SearchEmployeeById({required this.id});

  @override
  List<Object?> get props => [id];
}

class FilterEmployees extends EmployeeEvent {
  final String? name;
  final String? email;
  final String? mobile;
  final String? country;

  const FilterEmployees({this.name, this.email, this.mobile, this.country});

  @override
  List<Object?> get props => [name, email, mobile, country];
}

class ClearFilter extends EmployeeEvent {
  const ClearFilter();
}

class LoadCountries extends EmployeeEvent {
  const LoadCountries();
}

class CreateEmployee extends EmployeeEvent {
  final Employee employee;

  const CreateEmployee({required this.employee});

  @override
  List<Object?> get props => [employee];
}

class UpdateEmployee extends EmployeeEvent {
  final Employee employee;

  const UpdateEmployee({required this.employee});

  @override
  List<Object?> get props => [employee];
}

class DeleteEmployee extends EmployeeEvent {
  final String id;

  const DeleteEmployee({required this.id});

  @override
  List<Object?> get props => [id];
}
