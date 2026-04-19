// lib/features/complete_profile/data/datasources/profile_datasource.dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_strings.dart';
import '../models/profile_model.dart';

class ProfileDataSource {
  final _sb = Supabase.instance.client;

  Future<void> upsert(ProfileModel p) =>
      _sb.from(AppStrings.tProfiles).upsert(p.toMap());

  Future<ProfileModel?> get(String uid) async {
    final d = await _sb.from(AppStrings.tProfiles).select().eq('id', uid).maybeSingle();
    return d == null ? null : ProfileModel.fromMap(d);
  }

  Future<String> uploadAvatar(String uid, File file) async {
    final ext  = file.path.split('.').last;
    final path = '$uid/avatar.$ext';
    await _sb.storage.from(AppStrings.bAvatars)
        .upload(path, file, fileOptions: const FileOptions(upsert: true));
    return _sb.storage.from(AppStrings.bAvatars).getPublicUrl(path);
  }
}
