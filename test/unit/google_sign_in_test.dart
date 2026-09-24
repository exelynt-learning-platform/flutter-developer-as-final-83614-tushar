import 'package:dartz/dartz.dart';
import 'package:employee_management/application/auth/auth_bloc.dart';
import 'package:employee_management/domain/auth/entities/app_user.dart';
import 'package:employee_management/domain/auth/repository/i_auth_repository.dart';
import 'package:employee_management/domain/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late AuthBloc authBloc;

  const testUser = AppUser(
    uid: '123',
    email: 'test@test.com',
    displayName: 'Test User',
    photoUrl: 'https://photo.url',
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

  group('Google Sign-In flow', () {
    blocTest<AuthBloc, AuthState>(
      'emits [loading, authenticated] on successful Google sign in',
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
      verify: (_) {
        verify(() => mockAuthRepository.signInWithGoogle()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, failure] when user cancels Google sign in',
      build: () {
        when(() => mockAuthRepository.signInWithGoogle()).thenAnswer(
          (_) async =>
              const Left(AuthFailure('Google sign-in was cancelled')),
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
      'emits [loading, failure] on Google sign in network error',
      build: () {
        when(() => mockAuthRepository.signInWithGoogle()).thenAnswer(
          (_) async =>
              const Left(NetworkFailure('Network error. Check your connection')),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
      expect: () => [
        const AuthState.loading(),
        const AuthState.failure(
            message: 'Network error. Check your connection'),
      ],
    );
  });
}
