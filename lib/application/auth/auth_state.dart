part of 'auth_bloc.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, failure, passwordResetSent }

class AuthState extends Equatable {
  final AuthStatus status;
  final AppUser user;
  final String? errorMessage;

  const AuthState._({
    required this.status,
    this.user = AppUser.empty,
    this.errorMessage,
  });

  const AuthState.initial() : this._(status: AuthStatus.initial);
  const AuthState.loading() : this._(status: AuthStatus.loading);
  const AuthState.authenticated({required AppUser user})
      : this._(status: AuthStatus.authenticated, user: user);
  const AuthState.unauthenticated()
      : this._(status: AuthStatus.unauthenticated);
  const AuthState.failure({required String message})
      : this._(status: AuthStatus.failure, errorMessage: message);
  const AuthState.passwordResetSent()
      : this._(status: AuthStatus.passwordResetSent);

  @override
  List<Object?> get props => [status, user, errorMessage];
}
