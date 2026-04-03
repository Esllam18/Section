// lib/features/complete_profile/data/models/profile_model.dart

class ProfileModel {
  final String id;
  final String fullName;
  final String? phone;
  final String college;
  final String yearOfStudy;
  final String? avatarUrl;
  final DateTime? createdAt;

  const ProfileModel({
    required this.id,
    required this.fullName,
    this.phone,
    required this.college,
    required this.yearOfStudy,
    this.avatarUrl,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'full_name': fullName,
        'phone': phone,
        'college': college,
        'year_of_study': yearOfStudy,
        'avatar_url': avatarUrl,
      };

  factory ProfileModel.fromMap(Map<String, dynamic> map) => ProfileModel(
        id: map['id'] as String,
        fullName: map['full_name'] as String? ?? '',
        phone: map['phone'] as String?,
        college: map['college'] as String? ?? '',
        yearOfStudy: map['year_of_study'] as String? ?? '',
        avatarUrl: map['avatar_url'] as String?,
        createdAt: map['created_at'] != null
            ? DateTime.tryParse(map['created_at'] as String)
            : null,
      );
}
