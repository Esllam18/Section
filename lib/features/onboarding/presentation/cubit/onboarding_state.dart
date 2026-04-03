part of 'onboarding_cubit.dart';

class OnboardingState {
  final int currentPage;
  final bool isDone;
  const OnboardingState({required this.currentPage, this.isDone = false});
  OnboardingState copyWith({int? currentPage, bool? isDone}) =>
      OnboardingState(
          currentPage: currentPage ?? this.currentPage,
          isDone: isDone ?? this.isDone);
}
