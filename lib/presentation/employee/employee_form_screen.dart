import 'package:employee_management/application/employee/employee_bloc.dart';
import 'package:employee_management/domain/core/validators/validators.dart';
import 'package:employee_management/domain/employee/entities/employee.dart';
import 'package:employee_management/presentation/core/widgets/app_text_field.dart';
import 'package:employee_management/presentation/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EmployeeFormScreen extends StatefulWidget {
  final String? employeeId;

  const EmployeeFormScreen({super.key, this.employeeId});

  bool get isEditing => employeeId != null;

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _stateController = TextEditingController();
  final _districtController = TextEditingController();

  String? _selectedCountry;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    context.read<EmployeeBloc>().add(const LoadCountries());
    if (widget.isEditing) {
      final existing = context
          .read<EmployeeBloc>()
          .state
          .employees
          .where((e) => e.id == widget.employeeId)
          .firstOrNull;
      if (existing != null) {
        _populateForm(existing);
      } else {
        context.read<EmployeeBloc>().add(
              SearchEmployeeById(id: widget.employeeId!),
            );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  void _populateForm(Employee employee) {
    if (_isInitialized) return;
    _nameController.text = employee.name;
    _emailController.text = employee.email;
    _mobileController.text = employee.mobile;
    _stateController.text = employee.state;
    _districtController.text = employee.district;
    _selectedCountry = employee.country;
    _isInitialized = true;
  }

  void _onSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final employee = Employee(
      id: widget.employeeId ?? '',
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      mobile: _mobileController.text.trim(),
      country: _selectedCountry ?? '',
      state: _stateController.text.trim(),
      district: _districtController.text.trim(),
    );

    if (widget.isEditing) {
      context.read<EmployeeBloc>().add(UpdateEmployee(employee: employee));
    } else {
      context.read<EmployeeBloc>().add(CreateEmployee(employee: employee));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Employee' : 'Add Employee'),
      ),
      body: BlocConsumer<EmployeeBloc, EmployeeState>(
        listener: (context, state) {
          if (state.operationSuccess != null) {
            context.pop();
          }
        },
        builder: (context, state) {
          if (widget.isEditing && state.selectedEmployee != null) {
            _populateForm(state.selectedEmployee!);
          }

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Form(
                  key: _formKey,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          controller: _nameController,
                          label: 'Name',
                          hint: 'Enter employee name',
                          prefixIcon: const Icon(Icons.person_outlined),
                          validator: Validators.validateName,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'Enter employee email',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined),
                          validator: Validators.validateEmail,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _mobileController,
                          label: 'Mobile',
                          hint: 'Enter 10 digit mobile number',
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(Icons.phone_outlined),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          validator: Validators.validateMobile,
                        ),
                        const SizedBox(height: 16),
                        _buildCountryDropdown(state),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _stateController,
                          label: 'State',
                          hint: 'Enter state',
                          prefixIcon: const Icon(Icons.map_outlined),
                          validator: (v) =>
                              Validators.validateRequired(v, 'State'),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _districtController,
                          label: 'District',
                          hint: 'Enter district',
                          prefixIcon:
                              const Icon(Icons.location_city_outlined),
                          validator: (v) =>
                              Validators.validateRequired(v, 'District'),
                        ),
                        const SizedBox(height: 28),
                        PrimaryButton(
                          text: widget.isEditing ? 'Update' : 'Create',
                          isLoading: state.isLoading,
                          onPressed: _onSubmit,
                          icon: widget.isEditing ? Icons.save_rounded : Icons.add_rounded,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCountryDropdown(EmployeeState state) {
    final countries = state.countries.map((c) => c.country).toSet().toList()
      ..sort();

    return Semantics(
      label: 'Country',
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        initialValue: _selectedCountry != null && countries.contains(_selectedCountry)
            ? _selectedCountry
            : null,
        decoration: InputDecoration(
          labelText: 'Country',
          hintText: 'Select country',
          prefixIcon: const Icon(Icons.public_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        ),
        items: countries
            .map((c) => DropdownMenuItem(
                  value: c,
                  child: Text(c, overflow: TextOverflow.ellipsis),
                ))
            .toList(),
        onChanged: (value) => setState(() => _selectedCountry = value),
        validator: (v) => v == null || v.isEmpty ? 'Country is required' : null,
      ),
    );
  }
}
