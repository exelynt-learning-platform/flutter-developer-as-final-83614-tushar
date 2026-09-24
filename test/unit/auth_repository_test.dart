import 'package:dartz/dartz.dart';
import 'package:employee_management/domain/auth/entities/app_user.dart';
import 'package:employee_management/domain/core/error/exceptions.dart';
import 'package:employee_management/domain/core/error/failures.dart';
import 'package:employee_management/infrastructure/auth/data_source/auth_remote.dart';
import 'package:employee_management/infrastructure/auth/repository/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late MockAuthRemoteDataSource mockRemote;
  late AuthRepository repository;

  const testUser = AppUser(
    uid: '123',
    email: 'test@test.com',
    displayName: 'Test',
  );

  setUp(() {
    mockRemote = MockAuthRemoteDataSource();
    repository = AuthRepository(remoteDataSource: mockRemote);
  });

  group('AuthRepository', () {
    group('signInWithEmail', () {
      test('returns AppUser on success', () async {
        when(() => mockRemote.signInWithEmail(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => testUser);

        final result = await repository.signInWithEmail(
          email: 'test@test.com',
          password: '123456',
        );

        expect(result, const Right(testUser));
      });

      test('returns failure on AuthException', () async {
        when(() => mockRemote.signInWithEmail(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(AuthException(message: 'Invalid email or password'));

        final result = await repository.signInWithEmail(
          email: 'test@test.com',
          password: 'wrong',
        );

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<AuthFailure>()),
          (_) => fail('Expected failure'),
        );
      });
    });

    group('signUpWithEmail', () {
      test('returns AppUser on success', () async {
        when(() => mockRemote.signUpWithEmail(
              email: any(named: 'email'),
              password: any(named: 'password'),
              name: any(named: 'name'),
            )).thenAnswer((_) async => testUser);

        final result = await repository.signUpWithEmail(
          email: 'test@test.com',
          password: '123456',
          name: 'Test',
        );

        expect(result, const Right(testUser));
      });
    });

    group('forgotPassword', () {
      test('returns unit on success', () async {
        when(() => mockRemote.forgotPassword(email: any(named: 'email')))
            .thenAnswer((_) async {});

        final result = await repository.forgotPassword(email: 'test@test.com');

        expect(result, const Right(unit));
      });
    });

    group('signInWithGoogle', () {
      test('returns AppUser on success', () async {
        when(() => mockRemote.signInWithGoogle())
            .thenAnswer((_) async => testUser);

        final result = await repository.signInWithGoogle();

        expect(result, const Right(testUser));
      });

      test('returns failure when cancelled', () async {
        when(() => mockRemote.signInWithGoogle())
            .thenThrow(AuthException(message: 'Google sign-in was cancelled'));

        final result = await repository.signInWithGoogle();

        expect(result.isLeft(), true);
      });
    });

    group('signOut', () {
      test('returns unit on success', () async {
        when(() => mockRemote.signOut()).thenAnswer((_) async {});

        final result = await repository.signOut();

        expect(result, const Right(unit));
      });
    });

    group('authStateChanges', () {
      test('returns stream from remote', () {
        when(() => mockRemote.authStateChanges)
            .thenAnswer((_) => Stream.value(testUser));

        expect(repository.authStateChanges, emits(testUser));
      });
    });

    group('currentUser', () {
      test('returns user from remote', () {
        when(() => mockRemote.currentUser).thenReturn(testUser);

        expect(repository.currentUser, testUser);
      });
    });
  });
}
