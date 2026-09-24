import 'package:employee_management/application/auth/auth_bloc.dart';
import 'package:employee_management/application/employee/employee_bloc.dart';
import 'package:employee_management/application/theme/theme_bloc.dart';
import 'package:employee_management/domain/auth/entities/app_user.dart';
import 'package:employee_management/domain/core/error/failures.dart';
import 'package:employee_management/domain/employee/entities/employee.dart';
import 'package:employee_management/presentation/core/widgets/employee_card.dart';
import 'package:employee_management/presentation/core/widgets/empty_state_view.dart';
import 'package:employee_management/presentation/core/widgets/error_view.dart';
import 'package:employee_management/presentation/core/widgets/loading_view.dart';
import 'package:employee_management/presentation/employee/employee_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';

class MockEmployeeBloc extends Mock implements EmployeeBloc {}

class MockAuthBloc extends Mock implements AuthBloc {}

class MockThemeBloc extends Mock implements ThemeBloc {}

class FakeEmployeeEvent extends Fake implements EmployeeEvent {}

class FakeAuthEvent extends Fake implements AuthEvent {}

class FakeThemeEvent extends Fake implements ThemeEvent {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeEmployeeEvent());
    registerFallbackValue(FakeAuthEvent());
    registerFallbackValue(FakeThemeEvent());
  });

  late MockEmployeeBloc mockEmployeeBloc;
  late MockAuthBloc mockAuthBloc;
  late MockThemeBloc mockThemeBloc;

  const testEmployee = Employee(
    id: '1',
    name: 'John Doe',
    email: 'john@test.com',
    mobile: '1234567890',
    country: 'India',
    state: 'MH',
    district: 'Pune',
  );

  setUp(() {
    mockEmployeeBloc = MockEmployeeBloc();
    mockAuthBloc = MockAuthBloc();
    mockThemeBloc = MockThemeBloc();

    when(() => mockAuthBloc.state).thenReturn(
      const AuthState.authenticated(
        user: AppUser(uid: '1', email: 'user@test.com'),
      ),
    );
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockThemeBloc.state)
        .thenReturn(const ThemeState(themeMode: ThemeMode.light));
    when(() => mockThemeBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createTestWidget(EmployeeState state) {
    when(() => mockEmployeeBloc.state).thenReturn(state);
    when(() => mockEmployeeBloc.stream)
        .thenAnswer((_) => Stream.value(state));
    when(() => mockEmployeeBloc.add(any())).thenReturn(null);

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const EmployeeListScreen(),
        ),
        GoRoute(
          path: '/employee/add',
          builder: (context, state) => const Scaffold(body: Text('Add')),
        ),
        GoRoute(
          path: '/employee/:id',
          builder: (context, state) => const Scaffold(body: Text('Detail')),
        ),
        GoRoute(
          path: '/employee/:id/edit',
          builder: (context, state) => const Scaffold(body: Text('Edit')),
        ),
      ],
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<EmployeeBloc>.value(value: mockEmployeeBloc),
        BlocProvider<AuthBloc>.value(value: mockAuthBloc),
        BlocProvider<ThemeBloc>.value(value: mockThemeBloc),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  group('EmployeeListScreen', () {
    testWidgets('shows loading view when loading', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const EmployeeState(isLoading: true)),
      );
      await tester.pump();

      expect(find.byType(LoadingView), findsOneWidget);
    });

    testWidgets('shows error view with retry on failure', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const EmployeeState(failure: ServerFailure('Server error')),
        ),
      );
      await tester.pump();

      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.text('Server error'), findsWidgets);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('shows empty state when no employees', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const EmployeeState()),
      );
      await tester.pump();

      expect(find.byType(EmptyStateView), findsOneWidget);
    });

    testWidgets('shows employee cards when data loaded', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const EmployeeState(
          employees: [testEmployee],
          filteredEmployees: [testEmployee],
        )),
      );
      await tester.pump();

      expect(find.byType(EmployeeCard), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('shows offline banner when offline', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const EmployeeState(
          employees: [testEmployee],
          filteredEmployees: [testEmployee],
          isOffline: true,
        )),
      );
      await tester.pump();

      expect(find.text('Showing cached data — you are offline'), findsOneWidget);
    });
  });
}
