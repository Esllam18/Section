part of 'complete_profile_cubit.dart';

abstract class CompleteProfileState {}

class CompleteProfileInitial extends CompleteProfileState {}

class CompleteProfileLoading extends CompleteProfileState {}

class CompleteProfileImagePicked extends CompleteProfileState {
  final File imageFile;
  CompleteProfileImagePicked({required this.imageFile});
}

class CompleteProfileSuccess extends CompleteProfileState {}

class CompleteProfileError extends CompleteProfileState {
  final String message;
  CompleteProfileError(this.message);
}
