import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:section/features/auth/data/repositories/auth_repository.dart';
import 'register_state.dart';
class RegisterCubit extends Cubit<RegisterState> {
  final AuthRepository _r;
  RegisterCubit(this._r) : super(RegisterInitial());
  Future<void> register(String email, String pw) async {
    emit(RegisterLoading());
    try {
      final u = await _r.signUpWithEmail(email.trim(), pw);
      u != null ? emit(RegisterSuccess(u)) : emit(const RegisterError('Registration failed.'));
    } catch (e) {
      final m = e.toString().toLowerCase();
      emit(RegisterError(m.contains('already') ? 'Email already registered.' : 'Registration failed.'));
    }
  }
}
