// lib/core/constants/app_strings.dart

abstract final class AppStrings {
  // ── Supabase ──────────────────────────────────────────────────────────────
  static const String supabaseUrl = 'https://oehxqgqgplraqyceleeb.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9laHhxZ3FncGxyYXF5Y2VsZWViIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUxNDk1NzksImV4cCI6MjA5MDcyNTU3OX0.MNSVe_yavAuGxbiBHxcZ2HnYa6--Z-G8bsU4eCmEXwY';

  // ── App ───────────────────────────────────────────────────────────────────
  static const String appName = 'Section';
  static const String appTagline = 'YOUR MEDICAL TOOLS HUB';

  // ── SharedPreferences Keys ────────────────────────────────────────────────
  static const String kLanguageKey = 'selected_language';
  static const String kThemeKey = 'selected_theme';
  static const String kOnboardingKey = 'onboarding_seen';

  // ── Supabase Table Names ──────────────────────────────────────────────────
  static const String profilesTable = 'profiles';
  static const String productsTable = 'products';

  // ── Supabase Storage Buckets ──────────────────────────────────────────────
  static const String avatarsBucket = 'avatars';
}
