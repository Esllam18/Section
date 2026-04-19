// lib/features/complete_profile/data/models/profile_model.dart
// Maps old view fields (college, yearOfStudy) to actual DB columns (faculty, academic_year)

const _collegeToFaculty = {
  'Medicine': 'medicine', 'الطب البشري': 'medicine',
  'Dentistry': 'dentistry', 'طب الأسنان': 'dentistry',
  'Pharmacy': 'pharmacy', 'الصيدلة': 'pharmacy',
  'Nursing': 'nursing', 'التمريض': 'nursing',
  'Physical Therapy': 'physical_therapy', 'العلاج الطبيعي': 'physical_therapy',
  'Health Sciences': 'health_sciences', 'العلوم الصحية': 'health_sciences',
  'Veterinary': 'biomedical', 'الطب البيطري': 'biomedical',
  'Other': 'medicine',
};

class ProfileModel {
  final String id;
  final String fullName;
  final String? phone;
  final String? bio;
  final String college;       // display value
  final String yearOfStudy;   // display value e.g. "Year 1"
  final String? gender;
  final String? avatarUrl;
  final DateTime? createdAt;

  const ProfileModel({
    required this.id, required this.fullName, this.phone, this.bio,
    required this.college, required this.yearOfStudy, this.gender,
    this.avatarUrl, this.createdAt,
  });

  Map<String, dynamic> toMap() {
    // Parse year number from string like "Year 1", "السنة 1", or plain "1"
    final yearNum = int.tryParse(yearOfStudy.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
    final facultyKey = _collegeToFaculty[college] ?? 'medicine';
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'bio': bio,
      'faculty': facultyKey,
      'academic_year': yearNum,
      'avatar_url': avatarUrl,
      'is_profile_complete': true,
    };
  }

  factory ProfileModel.fromMap(Map<String, dynamic> m) => ProfileModel(
    id: m['id'],
    fullName: m['full_name'] ?? '',
    phone: m['phone'],
    bio: m['bio'],
    college: m['faculty'] ?? '',
    yearOfStudy: m['academic_year']?.toString() ?? '1',
    gender: m['gender'],
    avatarUrl: m['avatar_url'],
    createdAt: m['created_at'] != null ? DateTime.tryParse(m['created_at']) : null,
  );
}
