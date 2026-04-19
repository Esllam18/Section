// lib/core/validators/validators.dart
/// Centralised form validators — bilingual (AR / EN).
abstract final class Validators {
  static String? email(String? v, {bool isAr = false}) {
    if (v == null || v.trim().isEmpty) {
      return isAr ? 'البريد مطلوب' : 'Email is required';
    }
    final ok = RegExp(r'^[\w.+-]+@[\w-]+\.[a-z]{2,}$', caseSensitive: false)
        .hasMatch(v.trim());
    return ok ? null : (isAr ? 'بريد إلكتروني غير صحيح' : 'Enter a valid email');
  }

  static String? password(String? v, {bool isAr = false}) {
    if (v == null || v.isEmpty) {
      return isAr ? 'كلمة المرور مطلوبة' : 'Password is required';
    }
    if (v.length < 8) {
      return isAr ? '8 أحرف على الأقل' : 'At least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(v)) {
      return isAr ? 'أضف حرفاً كبيراً واحداً' : 'Add at least one uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(v)) {
      return isAr ? 'أضف رقماً واحداً على الأقل' : 'Add at least one number';
    }
    return null;
  }

  static String? confirmPassword(String? v, String original, {bool isAr = false}) {
    if (v == null || v.isEmpty) {
      return isAr ? 'تأكيد كلمة المرور مطلوب' : 'Please confirm your password';
    }
    return v == original
        ? null
        : (isAr ? 'كلمتا المرور غير متطابقتين' : 'Passwords do not match');
  }

  static String? required(String? v, String field, {bool isAr = false}) {
    if (v == null || v.trim().isEmpty) {
      return isAr ? '$field مطلوب' : '$field is required';
    }
    return null;
  }

  static String? fullName(String? v, {bool isAr = false}) {
    if (v == null || v.trim().isEmpty) {
      return isAr ? 'الاسم مطلوب' : 'Full name is required';
    }
    if (v.trim().length < 3) {
      return isAr ? 'الاسم قصير جداً' : 'Name too short';
    }
    return null;
  }

  static String? phone(String? v, {bool isAr = false}) {
    if (v == null || v.trim().isEmpty) return null; // optional
    final digits = v.replaceAll(RegExp(r'[\s\-\+\(\)]'), '');
    if (digits.length < 7 || digits.length > 15) {
      return isAr ? 'رقم هاتف غير صحيح' : 'Enter a valid phone number';
    }
    return null;
  }
}
