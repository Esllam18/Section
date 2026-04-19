// lib/features/auth/data/datasources/auth_datasource.dart
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_strings.dart';

class AuthDataSource {
  final _sb = Supabase.instance.client;
  final _google = GoogleSignIn(
    clientId: AppStrings.googleWebClientId,
    scopes: ['email', 'profile'],
  );

  Future<AuthResponse> signUp({required String email, required String password}) =>
      _sb.auth.signUp(email: email, password: password);

  Future<AuthResponse> signIn({required String email, required String password}) =>
      _sb.auth.signInWithPassword(email: email, password: password);

  Future<void> signOut() => _sb.auth.signOut();

  Future<void> resetPassword(String email) =>
      _sb.auth.resetPasswordForEmail(email);

  Future<AuthResponse> signInWithGoogle() async {
    final user = await _google.signIn();
    if (user == null) throw Exception('Google sign-in cancelled');
    final auth = await user.authentication;
    if (auth.idToken == null) throw Exception('No ID token from Google');
    return _sb.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: auth.idToken!,
      accessToken: auth.accessToken,
    );
  }

  Session? get session => _sb.auth.currentSession;
  User?    get user    => _sb.auth.currentUser;
}
