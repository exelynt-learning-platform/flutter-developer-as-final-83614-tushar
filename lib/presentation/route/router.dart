import 'dart:async';
import 'package:employee_management/application/auth/auth_bloc.dart';
import 'package:employee_management/locator.dart';
import 'package:employee_management/presentation/auth/forgot_password_screen.dart';
import 'package:employee_management/presentation/auth/login_screen.dart';
import 'package:employee_management/presentation/auth/register_screen.dart';
import 'package:employee_management/presentation/employee/employee_detail_screen.dart';
import 'package:employee_management/presentation/employee/employee_form_screen.dart';
import 'package:employee_management/presentation/employee/employee_list_screen.dart';
import 'package:employee_management/presentation/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  refreshListenable: GoRouterRefreshStream(locator<AuthBloc>().stream),
  redirect: (context, state) {
    if (state.matchedLocation == '/splash') {
      return null;
    }
    final authState = locator<AuthBloc>().state;
    final isAuthenticated = authState.status == AuthStatus.authenticated;
    final isAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register' ||
        state.matchedLocation == '/forgot-password';

    if (!isAuthenticated && !isAuthRoute) {
      return '/login';
    }
    if (isAuthenticated && isAuthRoute) {
      return '/';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const EmployeeListScreen(),
    ),
    GoRoute(
      path: '/employee/add',
      builder: (context, state) => const EmployeeFormScreen(),
    ),
    GoRoute(
      path: '/employee/:id',
      builder: (context, state) =>
          EmployeeDetailScreen(employeeId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/employee/:id/edit',
      builder: (context, state) =>
          EmployeeFormScreen(employeeId: state.pathParameters['id']!),
    ),
  ],
);
