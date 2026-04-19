import 'package:equatable/equatable.dart';
import 'package:section/features/auth/data/models/user_model.dart';
abstract class LoginState extends Equatable { const LoginState(); @override List<Object?> get props => []; }
class LoginInitial extends LoginState {}
class LoginLoading extends LoginState {}
class LoginSuccess extends LoginState { final UserModel user; const LoginSuccess(this.user); @override List<Object?> get props => [user]; }
class LoginError extends LoginState { final String message; const LoginError(this.message); @override List<Object?> get props => [message]; }
