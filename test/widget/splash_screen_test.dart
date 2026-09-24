import 'package:employee_management/application/auth/auth_bloc.dart';
import 'package:employee_management/domain/auth/entities/app_user.dart';
import 'package:employee_management/presentation/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

class FakeAuthEvent extends Fake implements AuthEvent {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUpAll(() {
    registerFallbackValue(FakeAuthEvent());
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(const AuthState.unauthenticated());
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createTestWidget({required AuthState authState}) {
    when(() => mockAuthBloc.state).thenReturn(authState);

    final router = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(body: Text('Login Screen')),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('Home Screen')),
        ),
      ],
    );

    return BlocProvider<AuthBloc>.value(
      value: mockAuthBloc,
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('SplashScreen renders title, subtitle, and loader', (tester) async {
    await tester.pumpWidget(
      createTestWidget(authState: const AuthState.unauthenticated()),
    );

    expect(find.text('Employee Management'), findsOneWidget);
    expect(find.text('Streamlined Workforce Portal'), findsOneWidget);
    expect(find.text('Starting application...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets('SplashScreen navigates to login when unauthenticated', (tester) async {
    await tester.pumpWidget(
      createTestWidget(authState: const AuthState.unauthenticated()),
    );

    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pumpAndSettle();

    expect(find.text('Login Screen'), findsOneWidget);
  });

  testWidgets('SplashScreen navigates to home when authenticated', (tester) async {
    const user = AppUser(uid: '123', email: 'test@test.com', displayName: 'Test', photoUrl: '');
    await tester.pumpWidget(
      createTestWidget(authState: const AuthState.authenticated(user: user)),
    );

    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pumpAndSettle();

    expect(find.text('Home Screen'), findsOneWidget);
  });
}
