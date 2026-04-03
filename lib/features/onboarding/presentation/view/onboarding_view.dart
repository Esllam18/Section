// lib/features/onboarding/presentation/view/onboarding_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/animations/app_animations.dart';
import '../../../../core/animations/app_durations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/navigation/navigation.dart';
import '../../../../core/responsive/responsive_extension.dart';
import '../../../../core/widgets/custom_button.dart';
import '../cubit/onboarding_cubit.dart';
import '../widgets/onboarding_dots_widget.dart';
import '../widgets/onboarding_page_widget.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});
  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  late final PageController _pc;

  @override
  void initState() {
    super.initState();
    _pc = PageController();
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _next(OnboardingCubit cubit) {
    if (cubit.isLastPage) {
      _finish(cubit);
    } else {
      _pc.nextPage(
          duration: AppDurations.pageTransition,
          curve: Curves.easeInOutCubic);
    }
  }

  Future<void> _finish(OnboardingCubit cubit) async {
    await cubit.complete();
    if (!mounted) return;
    Navigation.offAllNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listener: (_, s) {
        if (s.isDone) Navigation.offAllNamed(AppRoutes.login);
      },
      builder: (context, state) {
        final cubit = context.read<OnboardingCubit>();
        final isLast = cubit.isLastPage;
        return Scaffold(
          body: SafeArea(
            child: Column(children: [
              Align(
                alignment: AlignmentDirectional.topEnd,
                child: Padding(
                  padding: context.rOnly(top: 8, right: 16),
                  child: TextButton(
                    onPressed: () => _finish(cubit),
                    child: Text('skip'.tr(context),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.45))),
                  ),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pc,
                  onPageChanged: cubit.onPageChanged,
                  physics: const BouncingScrollPhysics(),
                  children: const [
                    OnboardingPageWidget(index: 0),
                    OnboardingPageWidget(index: 1),
                    OnboardingPageWidget(index: 2),
                  ],
                ),
              ),
              OnboardingDotsWidget(
                  currentPage: state.currentPage,
                  totalPages: OnboardingCubit.totalPages),
              const SizedBox(height: 24),
              Padding(
                padding: context.rSymmetric(horizontal: 24),
                child: AppAnimations.combined(
                  type: CombineType.fadeSlide,
                  duration: AppDurations.veryShort,
                  direction: SlideDirection.up,
                  slideDistance: 16,
                  child: CustomButton(
                    label: isLast
                        ? 'get_started'.tr(context)
                        : 'next'.tr(context),
                    onTap: () => _next(cubit),
                    suffixIcon: Icon(
                      isLast
                          ? Icons.rocket_launch_rounded
                          : Icons.arrow_forward_rounded,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ]),
          ),
        );
      },
    );
  }
}
