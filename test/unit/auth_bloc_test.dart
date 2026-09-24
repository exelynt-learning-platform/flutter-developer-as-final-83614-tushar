import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:employee_management/application/auth/auth_bloc.dart';
import 'package:employee_management/domain/auth/entities/app_user.dart';
import 'package:employee_management/domain/auth/repository/i_auth_repository.dart';
import 'package:employee_management/domain/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late AuthBloc authBloc;

  const testUser = AppUser(
    uid: '123',
    email: 'test@test.com',
    displayName: 'Test User',
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    when(() => mockAuthRepository.authStateChanges)
        .thenAnswer((_) => const Stream.empty());
    authBloc = AuthBloc(authRepository: mockAuthRepository);
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    test('initial state is AuthState.initial', () {
      expect(authBloc.state.status, AuthStatus.initial);
    });

    blocTest<AuthBloc, AuthState>(
      'emits [loading, authenticated] on successful sign in',
      build: () {
        when(() => mockAuthRepository.signInWithEmail(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => const Right(testUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const AuthSignInRequested(email: 'test@test.com', password: '123456'),
      ),
      expect: () => [
        const AuthState.loading(),
        const AuthState.authenticated(user: testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, failure] on sign in failure',
      build: () {
        when(() => mockAuthRepository.signInWithEmail(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer(
          (_) async => const Left(AuthFailure('Invalid email or password')),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const AuthSignInRequested(email: 'test@test.com', password: 'wrong'),
      ),
      expect: () => [
        const AuthState.loading(),
        const AuthState.failure(message: 'Invalid email or password'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, authenticated] on successful sign up',
      build: () {
        when(() => mockAuthRepository.signUpWithEmail(
              email: any(named: 'email'),
              password: any(named: 'password'),
              name: any(named: 'name'),
            )).thenAnswer((_) async => const Right(testUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const AuthSignUpRequested(
          email: 'test@test.com',
          password: '123456',
          name: 'Test User',
        ),
      ),
      expect: () => [
        const AuthState.loading(),
        const AuthState.authenticated(user: testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, passwordResetSent] on forgot password success',
      build: () {
        when(() => mockAuthRepository.forgotPassword(
              email: any(named: 'email'),
            )).thenAnswer((_) async => const Right(unit));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const AuthForgotPasswordRequested(email: 'test@test.com'),
      ),
      expect: () => [
        const AuthState.loading(),
        const AuthState.passwordResetSent(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, authenticated] on Google sign in success',
      build: () {
        when(() => mockAuthRepository.signInWithGoogle())
            .thenAnswer((_) async => const Right(testUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
      expect: () => [
        const AuthState.loading(),
        const AuthState.authenticated(user: testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, failure] on Google sign in failure',
      build: () {
        when(() => mockAuthRepository.signInWithGoogle()).thenAnswer(
          (_) async => const Left(AuthFailure('Google sign-in was cancelled')),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
      expect: () => [
        const AuthState.loading(),
        const AuthState.failure(message: 'Google sign-in was cancelled'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [unauthenticated] on sign out',
      build: () {
        when(() => mockAuthRepository.signOut())
            .thenAnswer((_) async => const Right(unit));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthSignOutRequested()),
      expect: () => [
        const AuthState.unauthenticated(),
      ],
    );
  });
}
