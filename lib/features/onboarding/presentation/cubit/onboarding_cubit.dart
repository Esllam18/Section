import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/helpers/onboarding_cache_helper.dart';
part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(const OnboardingState(0));
  static const total = 3;
  void changePage(int i) => emit(OnboardingState(i));
  bool get isLast => state.page == total - 1;
  Future<void> finish() async {
    await OnboardingCacheHelper.markOnboardingSeen();
    emit(const OnboardingState(0, done: true));
  }
}
