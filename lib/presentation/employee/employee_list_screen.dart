import 'package:employee_management/application/auth/auth_bloc.dart';
import 'package:employee_management/application/employee/employee_bloc.dart';
import 'package:employee_management/application/theme/theme_bloc.dart';
import 'package:employee_management/presentation/core/widgets/confirmation_dialog.dart';
import 'package:employee_management/presentation/core/widgets/employee_card.dart';
import 'package:employee_management/presentation/core/widgets/empty_state_view.dart';
import 'package:employee_management/presentation/core/widgets/error_view.dart';
import 'package:employee_management/presentation/core/widgets/loading_view.dart';
import 'package:employee_management/presentation/employee/widget/employee_filter.dart';
import 'package:employee_management/presentation/employee/widget/employee_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<EmployeeBloc>().add(const LoadEmployees());
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<EmployeeBloc>();
    final future = bloc.stream
        .firstWhere((state) => !state.isLoading)
        .timeout(const Duration(seconds: 4), onTimeout: () => bloc.state);
    bloc.add(const RefreshEmployees());
    try {
      await future;
    } catch (_) {}
  }

  void _onDelete(String id) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete Employee',
      message: 'Are you sure you want to delete this employee? This action cannot be undone.',
      confirmText: 'Delete',
      isDestructive: true,
    );
    if (confirmed == true && mounted) {
      context.read<EmployeeBloc>().add(DeleteEmployee(id: id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Employees'),
            const SizedBox(width: 8),
            BlocBuilder<EmployeeBloc, EmployeeState>(
              buildWhen: (prev, curr) =>
                  prev.filteredEmployees.length != curr.filteredEmployees.length,
              builder: (context, state) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${state.filteredEmployees.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          Tooltip(
            message: 'Toggle theme',
            child: IconButton(
              icon: Icon(
                context.watch<ThemeBloc>().state.themeMode == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: () =>
                  context.read<ThemeBloc>().add(const ToggleTheme()),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context, authState),
      body: BlocConsumer<EmployeeBloc, EmployeeState>(
        listener: (context, state) {
          if (state.operationSuccess != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.operationSuccess!)),
            );
          }
          if (state.failure != null && !state.isLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure!.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              if (state.isOffline)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Text(
                    'Showing cached data — you are offline',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      fontSize: 12,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: EmployeeSearchBar(
                  currentQuery: state.searchId,
                  onSearchById: (id) {
                    context.read<EmployeeBloc>().add(SearchEmployeeById(id: id));
                  },
                ),
              ),
              EmployeeFilterBar(
                onFilter: (name, email, mobile, country) {
                  context.read<EmployeeBloc>().add(FilterEmployees(
                        name: name,
                        email: email,
                        mobile: mobile,
                        country: country,
                      ));
                },
                onClear: () {
                  context.read<EmployeeBloc>().add(const ClearFilter());
                },
                hasActiveFilters: state.hasActiveFilters,
              ),
              Expanded(child: _buildBody(context, state)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/employee/add');
          if (context.mounted) {
            context.read<EmployeeBloc>().add(const LoadEmployees());
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Employee'),
        tooltip: 'Add new employee',
      ),
    );
  }

  Widget _buildBody(BuildContext context, EmployeeState state) {
    if (state.isLoading && state.employees.isEmpty) {
      return const LoadingView(message: 'Loading employees...');
    }

    if (state.failure != null && state.employees.isEmpty) {
      return ErrorView(
        message: state.failure!.message,
        onRetry: () =>
            context.read<EmployeeBloc>().add(const LoadEmployees()),
      );
    }

    if (state.filteredEmployees.isEmpty) {
      return EmptyStateView(
        message: state.hasActiveFilters
            ? 'No employees match the filters'
            : 'No employees found',
        icon: Icons.people_outline,
        actionLabel: state.hasActiveFilters ? 'Clear Filters' : null,
        onAction: state.hasActiveFilters
            ? () => context.read<EmployeeBloc>().add(const ClearFilter())
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 900) {
            return _buildGrid(state, 3);
          } else if (constraints.maxWidth > 600) {
            return _buildGrid(state, 2);
          }
          return _buildList(state);
        },
      ),
    );
  }

  Widget _buildList(EmployeeState state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.filteredEmployees.length,
      itemBuilder: (context, index) {
        final employee = state.filteredEmployees[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: EmployeeCard(
            employee: employee,
            onTap: () async {
              await context.push('/employee/${employee.id}');
              if (context.mounted) {
                context.read<EmployeeBloc>().add(const LoadEmployees());
              }
            },
            onEdit: () async {
              await context.push('/employee/${employee.id}/edit');
              if (context.mounted) {
                context.read<EmployeeBloc>().add(const LoadEmployees());
              }
            },
            onDelete: () => _onDelete(employee.id),
          ),
        );
      },
    );
  }

  Widget _buildGrid(EmployeeState state, int columns) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: 2.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: state.filteredEmployees.length,
      itemBuilder: (context, index) {
        final employee = state.filteredEmployees[index];
        return EmployeeCard(
          employee: employee,
          onTap: () async {
            await context.push('/employee/${employee.id}');
            if (context.mounted) {
              context.read<EmployeeBloc>().add(const LoadEmployees());
            }
          },
          onEdit: () async {
            await context.push('/employee/${employee.id}/edit');
            if (context.mounted) {
              context.read<EmployeeBloc>().add(const LoadEmployees());
            }
          },
          onDelete: () => _onDelete(employee.id),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context, AuthState authState) {
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withValues(alpha: 0.8),
                ],
              ),
            ),
            accountName: Text(
              authState.user.displayName.isNotEmpty
                  ? authState.user.displayName
                  : 'User',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            accountEmail: Text(
              authState.user.email,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 13,
              ),
            ),
            currentAccountPicture: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: authState.user.photoUrl.isNotEmpty
                    ? NetworkImage(authState.user.photoUrl)
                    : null,
                child: authState.user.photoUrl.isEmpty
                    ? Text(
                        authState.user.displayName.isNotEmpty
                            ? authState.user.displayName[0].toUpperCase()
                            : 'U',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      )
                    : null,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Employees'),
            selected: true,
            selectedColor: colorScheme.primary,
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
          ),
        ],
      ),
    );
  }
}
