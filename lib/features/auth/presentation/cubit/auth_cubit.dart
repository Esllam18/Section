// lib/features/auth/presentation/cubit/auth_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  final _repo = AuthRepository();

  // ── Sign Up ───────────────────────────────────────────────────────────────
  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final res = await _repo.signUp(email: email, password: password);
      if (res.user != null) {
        emit(AuthSuccess(user: res.user!, needsProfile: true));
      } else {
        emit(const AuthError('Sign-up failed. Please try again.'));
      }
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ── Sign In ───────────────────────────────────────────────────────────────
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final res = await _repo.signIn(email: email, password: password);
      if (res.user != null) {
        emit(AuthSuccess(user: res.user!, needsProfile: false));
      } else {
        emit(const AuthError('Login failed. Please try again.'));
      }
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ── Google ────────────────────────────────────────────────────────────────
  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      final res = await _repo.signInWithGoogle();
      if (res.user != null) {
        // Check if profile already exists
        final profile = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', res.user!.id)
            .maybeSingle();
        final needsProfile = profile == null ||
            (profile['full_name'] as String?)?.isEmpty != false;
        emit(AuthSuccess(user: res.user!, needsProfile: needsProfile));
      } else {
        emit(const AuthError('Google sign-in failed.'));
      }
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ── Reset Password ────────────────────────────────────────────────────────
  Future<void> resetPassword(String email) async {
    emit(AuthLoading());
    try {
      await _repo.resetPassword(email);
      emit(const AuthResetEmailSent());
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _repo.signOut();
    emit(AuthInitial());
  }
}
