// lib/features/onboarding/presentation/view/onboarding_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/animations/app_durations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/navigation/navigation.dart';
import '../../../../core/responsive/responsive_extension.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/gap.dart';
import '../cubit/onboarding_cubit.dart';
import 'onboarding_data.dart';
import '../widgets/onboarding_page_widget.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});
  @override
  State<OnboardingView> createState() => _State();
}

class _State extends State<OnboardingView> {
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

  Future<void> _next(OnboardingCubit c) async {
    if (c.isLast) {
      await c.finish();
      if (mounted) Navigation.offAllNamed(AppRoutes.login);
    } else {
      _pc.nextPage(duration: AppDurations.normal, curve: Curves.easeInOutCubic);
    }
  }

  Future<void> _skip(OnboardingCubit c) async {
    await c.finish();
    if (mounted) Navigation.offAllNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final isAR = context.watch<LocaleCubit>().isArabic;
    return BlocBuilder<OnboardingCubit, OnboardingState>(builder: (ctx, st) {
      final cubit = ctx.read<OnboardingCubit>();
      return Scaffold(
          body: SafeArea(
              child: Column(children: [
        // Skip
        Padding(
            padding: ctx.rSym(h: 12, v: 6),
            child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: AnimatedOpacity(
                    opacity: cubit.isLast ? 0 : 1,
                    duration: AppDurations.fast,
                    child: TextButton(
                        onPressed: cubit.isLast ? null : () => _skip(cubit),
                        child: Text(isAR ? 'تخطى' : 'Skip'))))),
        // Pages
        Expanded(
            child: PageView.builder(
                controller: _pc,
                onPageChanged: cubit.changePage,
                physics: const BouncingScrollPhysics(),
                itemCount: kOnboardingPages.length,
                itemBuilder: (_, i) => OnboardingPageWidget(
                    data: kOnboardingPages[i], isAR: isAR))),
        // Dots
        SmoothPageIndicator(
            controller: _pc,
            count: OnboardingCubit.total,
            effect: ExpandingDotsEffect(
                activeDotColor: Theme.of(ctx).colorScheme.primary,
                dotColor:
                    Theme.of(ctx).colorScheme.outline.withOpacity(0.28),
                dotHeight: 8,
                dotWidth: 8,
                expansionFactor: 3.2,
                spacing: 6)),
        Gap(ctx.r(26)),
        // Button
        Padding(
            padding: ctx.rSym(h: 24),
            child: CustomButton(
                label: cubit.isLast
                    ? (isAR ? 'ابدأ الآن' : 'Get Started')
                    : (isAR ? 'التالي' : 'Next'),
                onTap: () => _next(cubit),
                trailing: Icon(
                    cubit.isLast
                        ? Icons.rocket_launch_rounded
                        : (isAR
                            ? Icons.arrow_back_rounded
                            : Icons.arrow_forward_rounded),
                    color: AppColors.white,
                    size: 18))),
        const Gap(32),
      ])));
    });
  }
}
