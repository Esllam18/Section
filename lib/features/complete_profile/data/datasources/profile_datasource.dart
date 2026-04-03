// lib/features/complete_profile/data/datasources/profile_datasource.dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_strings.dart';
import '../models/profile_model.dart';

class ProfileDataSource {
  final _client = Supabase.instance.client;

  Future<void> upsertProfile(ProfileModel profile) async {
    await _client
        .from(AppStrings.profilesTable)
        .upsert(profile.toMap());
  }

  Future<ProfileModel?> getProfile(String userId) async {
    final data = await _client
        .from(AppStrings.profilesTable)
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    return ProfileModel.fromMap(data);
  }

  Future<String> uploadAvatar(String userId, File file) async {
    final ext = file.path.split('.').last;
    final path = '$userId/avatar.$ext';

    await _client.storage
        .from(AppStrings.avatarsBucket)
        .upload(path, file, fileOptions: const FileOptions(upsert: true));

    return _client.storage
        .from(AppStrings.avatarsBucket)
        .getPublicUrl(path);
  }
}
