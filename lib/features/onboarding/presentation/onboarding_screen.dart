// lib/features/onboarding/presentation/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:section/core/constants/app_assets.dart';
import 'package:section/core/constants/app_colors.dart';
import 'package:section/core/constants/app_sizes.dart';
import 'package:section/core/localization/locale_cubit.dart';
import 'package:section/core/localization/locale_state.dart';
import 'package:section/core/services/navigation/navigation.dart';
import 'package:section/core/widgets/custom_button.dart';
import 'package:section/features/auth/presentation/screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (mounted) Navigation.offAll(const LoginScreen());
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (_, locale) {
        final isAr = locale.locale.languageCode == 'ar';
        final slides = _slides(isAr);
        final isLast = _page == slides.length - 1;

        return Scaffold(
          body: SafeArea(
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 60),
                    SmoothPageIndicator(
                      controller: _ctrl,
                      count: slides.length,
                      effect: ExpandingDotsEffect(
                        activeDotColor: AppColors.secondary,
                        dotColor: AppColors.dividerLight,
                        dotHeight: 8, dotWidth: 8, expansionFactor: 3,
                      ),
                    ),
                    TextButton(
                      onPressed: _finish,
                      child: Text(isAr ? 'تخطي' : 'Skip',
                        style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondaryLight)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _ctrl,
                  itemCount: slides.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (_, i) => _SlidePage(slide: slides[i]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSizes.md, 0, AppSizes.md, AppSizes.lg),
                child: CustomButton(
                  label: isLast ? (isAr ? 'ابدأ الآن' : 'Get Started') : (isAr ? 'التالي' : 'Next'),
                  onTap: () {
                    if (isLast) { _finish(); return; }
                    _ctrl.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
                  },
                  useGradient: true,
                ),
              ),
            ]),
          ),
        );
      },
    );
  }

  List<_Slide> _slides(bool isAr) => [
    _Slide(lottie: AppAssets.lottieOnboardingStore,
      title: isAr ? 'كل أدواتك الطبية في مكان واحد' : 'All your medical tools in one place',
      sub:   isAr ? 'تسوق السماعات والسكراب والكتب — مخصص لكليتك' : 'Shop stethoscopes, scrubs, books — curated for your faculty'),
    _Slide(lottie: AppAssets.lottieOnboardingComm,
      title: isAr ? 'تواصل مع زملائك في كل مكان' : 'Connect with medical students',
      sub:   isAr ? 'اسأل، شارك تجاربك، وانمُ معهم' : 'Ask questions, share experiences and grow together'),
    _Slide(lottie: AppAssets.lottieOnboardingStudy,
      title: isAr ? 'شارك وابحث عن مذكرات الدراسة' : 'Find and share study materials',
      sub:   isAr ? 'ادخل على المذكرات وملفات PDF والامتحانات القديمة' : 'Access notes, PDFs, past exams and more'),
    _Slide(lottie: AppAssets.lottieOnboardingAI,
      title: isAr ? 'مساعدك الذكي يدرس معك' : 'Your AI studies with you',
      sub:   isAr ? 'اسأل أي سؤال، اشرح لي الكريبس، ذاكر معي 24/7' : 'Ask anything — study anatomy, explain Krebs cycle, available 24/7'),
  ];
}

class _Slide { final String lottie, title, sub; const _Slide({required this.lottie, required this.title, required this.sub}); }

class _SlidePage extends StatelessWidget {
  final _Slide slide;
  const _SlidePage({required this.slide});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Lottie.asset(slide.lottie, height: 280, repeat: true),
      const SizedBox(height: 32),
      Text(slide.title, textAlign: TextAlign.center,
        style: const TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w700, fontSize: 24)),
      const SizedBox(height: 14),
      Text(slide.sub, textAlign: TextAlign.center,
        style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, color: AppColors.textSecondaryLight, height: 1.6)),
    ]),
  );
}
