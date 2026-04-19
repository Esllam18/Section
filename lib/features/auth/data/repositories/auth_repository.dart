import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:section/core/config/app_config.dart';
import 'package:section/core/services/supabase_service.dart';
import 'package:section/features/auth/data/models/user_model.dart';

class AuthRepository {
  final _c = SupabaseService.client;

  // ── For LoginCubit (returns UserModel?) ────────────────────────────────────
  Future<UserModel?> signInWithEmail(String email, String password) async {
    final r = await _c.auth.signInWithPassword(email: email, password: password);
    if (r.user == null) return null;
    return _buildUserModel(r.user!.id, r.user!.email ?? email);
  }

  Future<UserModel?> signUpWithEmail(String email, String password) async {
    final r = await _c.auth.signUp(email: email, password: password);
    if (r.user == null) return null;
    return UserModel(id: r.user!.id, email: email);
  }

  Future<UserModel?> signInWithGoogleAsUserModel() async {
    final r = await signInWithGoogle();
    if (r.user == null) return null;
    return _buildUserModel(r.user!.id, r.user!.email ?? '');
  }

  // ── For AuthCubit (returns AuthResponse) ───────────────────────────────────
  Future<AuthResponse> signIn({required String email, required String password}) =>
      _c.auth.signInWithPassword(email: email, password: password);

  Future<AuthResponse> signUp({required String email, required String password}) =>
      _c.auth.signUp(email: email, password: password);

  Future<AuthResponse> signInWithGoogle() async {
    final g = GoogleSignIn(clientId: AppConfig.googleClientId, scopes: ['email']);
    final u = await g.signIn();
    if (u == null) throw Exception('Google sign-in cancelled');
    final auth = await u.authentication;
    if (auth.idToken == null) throw Exception('No ID token from Google');
    return _c.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: auth.idToken!,
        accessToken: auth.accessToken);
  }

  // ── Shared ─────────────────────────────────────────────────────────────────
  Future<void> signOut() => _c.auth.signOut();
  Future<void> resetPassword(String email) => _c.auth.resetPasswordForEmail(email);
  Future<void> sendPasswordReset(String email) => _c.auth.resetPasswordForEmail(email);
  Future<void> updatePassword(String pw) =>
      _c.auth.updateUser(UserAttributes(password: pw));

  Future<bool> isProfileComplete(String uid) async {
    final d = await _c.from('profiles')
        .select('is_profile_complete').eq('id', uid).maybeSingle();
    return d?['is_profile_complete'] == true;
  }

  Future<UserModel?> _buildUserModel(String id, String email) async {
    final d = await _c.from('profiles').select().eq('id', id).maybeSingle();
    if (d == null) return UserModel(id: id, email: email);
    return UserModel.fromJson({...d, 'email': email});
  }
}
