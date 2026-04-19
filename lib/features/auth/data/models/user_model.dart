class UserModel {
  final String id, email;
  final String? fullName, username, avatarUrl, faculty;
  final int? academicYear;
  final bool isProfileComplete;
  const UserModel({required this.id, required this.email, this.fullName, this.username,
    this.avatarUrl, this.faculty, this.academicYear, this.isProfileComplete = false});
  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id: j['id'], email: j['email'] ?? '',
    fullName: j['full_name'], username: j['username'], avatarUrl: j['avatar_url'],
    faculty: j['faculty'], academicYear: j['academic_year'],
    isProfileComplete: j['is_profile_complete'] ?? false);
}
