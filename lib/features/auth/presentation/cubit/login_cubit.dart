import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:section/features/auth/data/repositories/auth_repository.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _r;
  LoginCubit(this._r) : super(LoginInitial());

  Future<void> login(String email, String pw) async {
    emit(LoginLoading());
    try {
      final u = await _r.signInWithEmail(email.trim(), pw);
      u != null ? emit(LoginSuccess(u)) : emit(const LoginError('Login failed.'));
    } catch (e) {
      emit(LoginError(_parse(e)));
    }
  }

  Future<void> loginWithGoogle() async {
    emit(LoginLoading());
    try {
      final u = await _r.signInWithGoogleAsUserModel();
      u != null ? emit(LoginSuccess(u)) : emit(const LoginError('Cancelled.'));
    } catch (e) {
      emit(LoginError(_parse(e)));
    }
  }

  String _parse(Object e) {
    final m = e.toString().toLowerCase();
    if (m.contains('invalid')) return 'Invalid email or password.';
    if (m.contains('network')) return 'Check your internet connection.';
    return 'Something went wrong. Try again.';
  }
}
