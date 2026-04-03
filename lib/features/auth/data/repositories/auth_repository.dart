// lib/features/auth/data/repositories/auth_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../datasources/auth_datasource.dart';

class AuthRepository {
  final _ds = AuthDataSource();

  Future<AuthResponse> signUp(
          {required String email, required String password}) =>
      _ds.signUp(email: email, password: password);

  Future<AuthResponse> signIn(
          {required String email, required String password}) =>
      _ds.signIn(email: email, password: password);

  Future<void> signOut() => _ds.signOut();

  Future<void> resetPassword(String email) => _ds.resetPassword(email);

  Future<AuthResponse> signInWithGoogle() => _ds.signInWithGoogle();

  Session? get currentSession => _ds.currentSession;
  User? get currentUser => _ds.currentUser;
}
