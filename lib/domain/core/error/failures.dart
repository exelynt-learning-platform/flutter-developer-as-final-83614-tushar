import 'package:equatable/equatable.dart';

abstract class AppFailure extends Equatable {
  final String message;

  const AppFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends AppFailure {
  const ServerFailure([super.message = 'Server error occurred']);
}

class NetworkFailure extends AppFailure {
  const NetworkFailure([super.message = 'Network error. Check your connection']);
}

class CacheFailure extends AppFailure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

class AuthFailure extends AppFailure {
  const AuthFailure([super.message = 'Authentication error']);
}

class UnknownFailure extends AppFailure {
  const UnknownFailure([super.message = 'Something went wrong']);
}
