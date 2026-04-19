// Onboarding page content
class OPage {
  final String titleAr, titleEn, subAr, subEn, localAsset;
  const OPage({required this.titleAr, required this.titleEn, required this.subAr,
    required this.subEn, required this.localAsset});
}

const kOnboardingPages = [
  OPage(
    titleAr: 'كل ما تحتاجه في مكان واحد',
    titleEn: 'Everything You Need',
    subAr: 'أدوات طبية، مواد دراسية، ومجتمع من الطلاب — كل ذلك في مكان واحد.',
    subEn: 'Medical tools, study materials and a student community — all in one place.',
    localAsset: 'assets/lottie/onboarding_store.json',
  ),
  OPage(
    titleAr: 'ادرس بشكل أذكى',
    titleEn: 'Study Smarter',
    subAr: 'تصفّح الكتب والامتحانات وملفات PDF المنظّمة حسب مادتك وكليتك.',
    subEn: 'Browse books, exams and PDFs organised by subject and college.',
    localAsset: 'assets/lottie/onboarding_study.json',
  ),
  OPage(
    titleAr: 'اسأل واحصل على إجابة فورية',
    titleEn: 'Ask Anything, Instantly',
    subAr: 'مساعدنا الذكي يجيب على أسئلتك الطبية فوراً في أي وقت.',
    subEn: 'Our AI assistant answers your medical questions instantly — anytime.',
    localAsset: 'assets/lottie/onboarding_ai.json',
  ),
];
