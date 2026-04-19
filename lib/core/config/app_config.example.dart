// lib/core/config/app_config.example.dart
// Copy to app_config.dart and fill your values — NEVER commit app_config.dart
abstract final class AppConfig {
  static const String appName = 'Section';
  static const String appVersion = '1.0.0';
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  static const String groqApiKey = 'YOUR_GROQ_KEY';
  static const String groqBaseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String groqModel = 'llama-3.3-70b-versatile';
  static const String googleClientId = 'YOUR_GOOGLE_CLIENT_ID';
  static const String paymobApiKey = 'YOUR_PAYMOB_API_KEY';
  static const String paymobSecretKey = 'YOUR_PAYMOB_SECRET_KEY';
  static const String paymobPublicKey = 'YOUR_PAYMOB_PUBLIC_KEY';
  static const String paymobBaseUrl = 'https://accept.paymob.com/api';
  static const int paymobCardIntegrationId = 0;
  static const int paymobWalletIntegrationId = 0;
  static const int paymobCashIntegrationId = 0;
  static const int paymobMerchantId = 0;
  static const String paymobIframeId = 'YOUR_IFRAME_ID';
}
