// lib/features/auth/presentation/cubit/auth_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/auth_repository.dart';
part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  final _repo = AuthRepository();

  Future<void> signUp({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      final res = await _repo.signUp(email: email, password: password);
      if (res.user != null) {
        emit(AuthSuccess(res.user!, needsProfile: true));
      } else {
        emit(const AuthFailure('Sign-up failed. Please try again.'));
      }
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      final res = await _repo.signIn(email: email, password: password);
      if (res.user != null) {
        emit(AuthSuccess(res.user!, needsProfile: false));
      } else {
        emit(const AuthFailure('Login failed. Please try again.'));
      }
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      final res = await _repo.signInWithGoogle();
      if (res.user == null) {
        emit(const AuthFailure('Google sign-in failed.'));
        return;
      }
      final profile = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', res.user!.id)
          .maybeSingle();
      final needsProfile = profile == null ||
          (profile['full_name'] as String?)?.isEmpty != false;
      emit(AuthSuccess(res.user!, needsProfile: needsProfile));
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> resetPassword(String email) async {
    emit(AuthLoading());
    try {
      await _repo.resetPassword(email);
      emit(const AuthResetSent());
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
