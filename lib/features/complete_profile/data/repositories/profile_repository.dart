// lib/features/complete_profile/data/repositories/profile_repository.dart
import 'dart:io';
import '../datasources/profile_datasource.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  final _ds = ProfileDataSource();
  Future<void> upsert(ProfileModel p)      => _ds.upsert(p);
  Future<ProfileModel?> get(String uid)    => _ds.get(uid);
  Future<String> uploadAvatar(String uid, File f) => _ds.uploadAvatar(uid, f);
}
