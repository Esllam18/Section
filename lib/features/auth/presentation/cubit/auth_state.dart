part of 'auth_cubit.dart';
abstract class AuthState { const AuthState(); }
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {
  final User user;
  final bool needsProfile;
  const AuthSuccess(this.user, {required this.needsProfile});
}
class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
}
class AuthResetSent extends AuthState { const AuthResetSent(); }
