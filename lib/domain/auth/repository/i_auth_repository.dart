import 'package:dartz/dartz.dart';
import 'package:employee_management/domain/auth/entities/app_user.dart';
import 'package:employee_management/domain/core/error/failures.dart';

abstract class IAuthRepository {
  Stream<AppUser> get authStateChanges;
  Future<Either<AppFailure, AppUser>> signInWithEmail({
    required String email,
    required String password,
  });
  Future<Either<AppFailure, AppUser>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  });
  Future<Either<AppFailure, Unit>> forgotPassword({required String email});
  Future<Either<AppFailure, AppUser>> signInWithGoogle();
  Future<Either<AppFailure, Unit>> signOut();
  AppUser get currentUser;
}
