part of 'complete_profile_cubit.dart';
abstract class CompleteProfileState {}
class CompleteProfileInitial  extends CompleteProfileState {}
class CompleteProfileLoading  extends CompleteProfileState {}
class ProfileImagePicked      extends CompleteProfileState { final File file; ProfileImagePicked(this.file); }
class CompleteProfileSuccess  extends CompleteProfileState {}
class CompleteProfileError    extends CompleteProfileState { final String message; CompleteProfileError(this.message); }
