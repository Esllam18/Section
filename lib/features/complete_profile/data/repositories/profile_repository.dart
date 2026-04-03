// lib/features/complete_profile/data/repositories/profile_repository.dart
import 'dart:io';
import '../datasources/profile_datasource.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  final _ds = ProfileDataSource();

  Future<void> upsertProfile(ProfileModel profile) =>
      _ds.upsertProfile(profile);

  Future<ProfileModel?> getProfile(String userId) =>
      _ds.getProfile(userId);

  Future<String> uploadAvatar(String userId, File file) =>
      _ds.uploadAvatar(userId, file);
}
