// lib/features/onboarding/presentation/cubit/onboarding_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/helpers/onboarding_cache_helper.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(const OnboardingState(currentPage: 0));
  static const int totalPages = 3;

  void onPageChanged(int i) => emit(state.copyWith(currentPage: i));
  bool get isLastPage => state.currentPage == totalPages - 1;

  Future<void> complete() async {
    await OnboardingCacheHelper.markOnboardingSeen();
    emit(state.copyWith(isDone: true));
  }
}
