import 'package:employee_management/application/auth/auth_bloc.dart';
import 'package:employee_management/application/employee/employee_bloc.dart';
import 'package:employee_management/application/theme/theme_bloc.dart';
import 'package:employee_management/locator.dart';
import 'package:employee_management/presentation/route/router.dart';
import 'package:employee_management/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: locator<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider.value(
          value: locator<ThemeBloc>()..add(const LoadTheme()),
        ),
        BlocProvider.value(
          value: locator<EmployeeBloc>()..add(const LoadEmployees()),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Employee Management',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.themeMode,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
