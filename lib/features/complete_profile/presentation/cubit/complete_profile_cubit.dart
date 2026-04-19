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
  final _repo    = ProfileRepository();
  final _picker  = ImagePicker();
  File? pickedImage;

  Future<void> pickImage() async {
    final x = await _picker.pickImage(source: ImageSource.gallery,
      maxWidth: 800, maxHeight: 800, imageQuality: 85);
    if (x != null) { pickedImage = File(x.path); emit(ProfileImagePicked(pickedImage!)); }
  }

  Future<void> save({required String fullName, String? phone, String? bio,
    required String college, required String yearOfStudy, String? gender}) async {
    emit(CompleteProfileLoading());
    try {
      final uid = Supabase.instance.client.auth.currentUser!.id;
      String? avatarUrl;
      if (pickedImage != null) avatarUrl = await _repo.uploadAvatar(uid, pickedImage!);
      await _repo.upsert(ProfileModel(
        id: uid, fullName: fullName.trim(), phone: phone?.trim(),
        bio: bio?.trim(), college: college, yearOfStudy: yearOfStudy,
        gender: gender, avatarUrl: avatarUrl));
      emit(CompleteProfileSuccess());
    } catch (e) { emit(CompleteProfileError(e.toString())); }
  }
}
