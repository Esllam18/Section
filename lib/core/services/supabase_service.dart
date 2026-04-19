import 'package:supabase_flutter/supabase_flutter.dart';
class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => client.auth;
  static SupabaseStorageClient get storage => client.storage;
  static User? get currentUser => auth.currentUser;
  static String? get currentUserId => currentUser?.id;
  static bool get isLoggedIn => currentUser != null;
  static Stream<AuthState> get authStateChanges => auth.onAuthStateChange;
}
