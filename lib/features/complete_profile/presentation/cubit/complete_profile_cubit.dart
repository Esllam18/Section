// lib/features/complete_profile/presentation/cubit/complete_profile_cubit.dart
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/profile_model.dart';
import '../../data/repositories/profile_repository.dart';

part 'complete_profile_state.dart';

class CompleteProfileCubit extends Cubit<CompleteProfileState> {
  CompleteProfileCubit() : super(CompleteProfileInitial());

  final _repo = ProfileRepository();
  final _picker = ImagePicker();

  File? pickedImage;

  // ── Pick image from gallery ───────────────────────────────────────────────
  Future<void> pickImage() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (xFile != null) {
      pickedImage = File(xFile.path);
      emit(CompleteProfileImagePicked(imageFile: pickedImage!));
    }
  }

  // ── Save profile ──────────────────────────────────────────────────────────
  Future<void> saveProfile({
    required String fullName,
    String? phone,
    required String college,
    required String yearOfStudy,
  }) async {
    emit(CompleteProfileLoading());
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;

      // Upload avatar if picked
      String? avatarUrl;
      if (pickedImage != null) {
        avatarUrl = await _repo.uploadAvatar(userId, pickedImage!);
      }

      final profile = ProfileModel(
        id: userId,
        fullName: fullName.trim(),
        phone: phone?.trim().isEmpty == true ? null : phone?.trim(),
        college: college,
        yearOfStudy: yearOfStudy,
        avatarUrl: avatarUrl,
      );

      await _repo.upsertProfile(profile);
      emit(CompleteProfileSuccess());
    } catch (e) {
      emit(CompleteProfileError(e.toString()));
    }
  }
}
