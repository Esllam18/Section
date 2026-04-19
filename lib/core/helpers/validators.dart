// lib/core/helpers/validators.dart
abstract final class Validators {
  static String? email(String? v, {String msg = 'Email is required'}) {
    if (v == null || v.trim().isEmpty) return msg;
    if (!RegExp(r'^[\w.+-]+@[\w-]+\.[a-z]{2,}$', caseSensitive: false)
        .hasMatch(v.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? v, {String msg = 'Password is required'}) {
    if (v == null || v.isEmpty) return msg;
    if (v.length < 8) return 'At least 8 characters required';
    if (!RegExp(r'[A-Z]').hasMatch(v))
      return 'Add at least one uppercase letter';
    if (!RegExp(r'[0-9]').hasMatch(v)) return 'Add at least one number';
    return null;
  }

  static String? confirmPassword(String? v, String original) {
    if (v == null || v.isEmpty) return 'Please confirm your password';
    if (v != original) return 'Passwords do not match';
    return null;
  }

  static String? required(String? v, String field) {
    if (v == null || v.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final digits = v.replaceAll(RegExp(r'[\s\-\+\(\)]'), '');
    if (digits.length < 7 || digits.length > 15)
      return 'Enter a valid phone number';
    return null;
  }

  static String? fullName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Full name is required';
    if (v.trim().length < 3) return 'Name must be at least 3 characters';
    return null;
  }
}
