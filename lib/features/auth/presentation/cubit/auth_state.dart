part of 'auth_cubit.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final User user;
  final bool needsProfile;
  const AuthSuccess({required this.user, required this.needsProfile});
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

class AuthResetEmailSent extends AuthState {
  const AuthResetEmailSent();
}
