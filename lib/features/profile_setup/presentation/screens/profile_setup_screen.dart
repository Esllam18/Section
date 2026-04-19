// lib/features/profile_setup/presentation/screens/profile_setup_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:section/core/constants/app_colors.dart';
import 'package:section/core/constants/app_sizes.dart';
import 'package:section/core/localization/locale_cubit.dart';
import 'package:section/core/localization/locale_state.dart';
import 'package:section/core/services/navigation/navigation.dart';
import 'package:section/core/services/supabase_service.dart';
import 'package:section/core/widgets/custom_button.dart';
import 'package:section/core/widgets/custom_snackbar.dart';
import 'package:section/core/widgets/custom_text_field.dart';
import 'package:section/layout/main_layout.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});
  @override State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  int _step = 0;
  bool _loading = false;

  // Step 1
  File? _avatar;
  final _nameCtrl = TextEditingController();
  final _userCtrl = TextEditingController();

  // Step 2
  String? _faculty;
  int _year = 1;
  String _uniType = 'public';

  // Step 3
  String _uniName = '';
  final _searchCtrl = TextEditingController();
  String _filter = '';

  static const _faculties = [
    ('medicine','طب بشري','Medicine'),
    ('dentistry','طب وجراحة الأسنان','Dentistry'),
    ('pharmacy','صيدلة','Pharmacy'),
    ('nursing','تمريض','Nursing'),
    ('physical_therapy','علاج طبيعي','Physical Therapy'),
    ('health_sciences','علوم صحية','Health Sciences'),
    ('medical_technology','تكنولوجيا طبية','Medical Technology'),
    ('biomedical','هندسة طبية حيوية','Biomedical'),
  ];

  static const _universities = [
    'Cairo University','Ain Shams University','Alexandria University',
    'Mansoura University','Assiut University','Tanta University',
    'Zagazig University','Minia University','Sohag University',
    'Fayoum University','Beni-Suef University','South Valley University',
    'Suez Canal University','Helwan University','Kafrelsheikh University',
    'Menoufia University','Damanhour University','Badr University',
    'Modern Sciences & Arts University (MSA)','Misr International University (MIU)',
    'October 6 University','Misr University for Science & Technology (MUST)',
    'Arab Academy for Science & Technology','Future University in Egypt',
    'Nile University','Delta University','Sinai University',
    'Modern University for Technology & Information (MTI)',
  ];

  @override void dispose() { _nameCtrl.dispose(); _userCtrl.dispose(); _searchCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null || _uniName.isEmpty) return;
    setState(() => _loading = true);
    try {
      String? avatarUrl;
      if (_avatar != null) {
        final ext = _avatar!.path.split('.').last;
        final path = '$userId/avatar.$ext';
        await SupabaseService.storage.from('avatars').upload(path, _avatar!, fileOptions: const FileOptions(upsert: true));
        avatarUrl = SupabaseService.storage.from('avatars').getPublicUrl(path);
      }
      await SupabaseService.client.from('profiles').update({
        'full_name': _nameCtrl.text.trim(),
        'username': _userCtrl.text.trim(),
        'faculty': _faculty ?? 'medicine',
        'academic_year': _year,
        'university_type': _uniType,
        'university_name': _uniName,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        'is_profile_complete': true,
      }).eq('id', userId);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('faculty', _faculty ?? 'medicine');
      await prefs.setInt('academic_year', _year);

      if (mounted) Navigation.offAll(const MainLayout());
    } catch (e) {
      if (mounted) { setState(() => _loading = false); CustomSnackBar.show(message: e.toString(), type: SnackBarType.error); }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (_, locale) {
        final isAr = locale.locale.languageCode == 'ar';
        return Scaffold(
          appBar: AppBar(
            title: Text(isAr ? 'أكمل ملفك الشخصي' : 'Complete Your Profile',
              style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
            leading: _step > 0 ? IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => setState(() => _step--)) : null,
          ),
          body: Column(children: [
            // Step progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
              child: Row(
                children: List.generate(3, (i) => Expanded(
                  child: Padding(padding: EdgeInsets.only(right: i < 2 ? 6 : 0),
                    child: AnimatedContainer(duration: const Duration(milliseconds: 300), height: 4,
                      decoration: BoxDecoration(
                        color: i <= _step ? AppColors.secondary : AppColors.dividerLight,
                        borderRadius: BorderRadius.circular(2)))))),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: KeyedSubtree(
                  key: ValueKey(_step),
                  child: _step == 0 ? _step1(isAr) : _step == 1 ? _step2(isAr) : _step3(isAr),
                ),
              ),
            ),
          ]),
        );
      },
    );
  }

  Widget _step1(bool isAr) => SingleChildScrollView(
    padding: const EdgeInsets.all(AppSizes.md),
    child: Column(children: [
      Text(isAr ? 'الصورة والمعلومات الأساسية' : 'Avatar & Basic Info',
        style: const TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w700, fontSize: 22), textAlign: TextAlign.center),
      const SizedBox(height: 24),
      GestureDetector(
        onTap: () async {
          final p = ImagePicker();
          final f = await p.pickImage(source: ImageSource.gallery, imageQuality: 80);
          if (f != null) setState(() => _avatar = File(f.path));
        },
        child: Stack(children: [
          CircleAvatar(radius: 50, backgroundColor: AppColors.backgroundLight,
            backgroundImage: _avatar != null ? FileImage(_avatar!) : null,
            child: _avatar == null ? const Icon(Icons.person, size: 50, color: AppColors.dividerLight) : null),
          Positioned(bottom: 0, right: 0,
            child: Container(padding: const EdgeInsets.all(7),
              decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
              child: const Icon(Icons.camera_alt, size: 16, color: Colors.white))),
        ]),
      ),
      const SizedBox(height: 24),
      CustomTextField(controller: _nameCtrl, hint: isAr ? 'الاسم الكامل' : 'Full Name', prefixIcon: Icons.person_outline,
        onChanged: (v) { final s = v.toLowerCase().replaceAll(' ', '_').replaceAll(RegExp(r'[^a-z0-9_]'), ''); setState(() => _userCtrl.text = s); }),
      const SizedBox(height: AppSizes.md),
      CustomTextField(controller: _userCtrl, hint: isAr ? 'اسم المستخدم' : 'Username', prefixIcon: Icons.alternate_email),
      const SizedBox(height: 32),
      CustomButton(label: isAr ? 'التالي' : 'Next', onTap: () { if (_nameCtrl.text.isNotEmpty) setState(() => _step = 1); else CustomSnackBar.show(message: isAr ? 'أدخل اسمك' : 'Enter your name', type: SnackBarType.warning); }, useGradient: true),
    ]),
  );

  Widget _step2(bool isAr) => SingleChildScrollView(
    padding: const EdgeInsets.all(AppSizes.md),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Center(child: Text(isAr ? 'المعلومات الأكاديمية' : 'Academic Info',
        style: const TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w700, fontSize: 22))),
      const SizedBox(height: 20),
      Text(isAr ? 'الكلية' : 'Faculty', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 15)),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: _faculties.map((f) {
        final sel = _faculty == f.$1;
        return GestureDetector(onTap: () => setState(() => _faculty = f.$1),
          child: AnimatedContainer(duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: sel ? AppColors.secondary.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: sel ? AppColors.secondary : AppColors.dividerLight, width: sel ? 2 : 1)),
            child: Text(isAr ? f.$2 : f.$3, style: TextStyle(fontFamily: 'Cairo', fontSize: 13,
              fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
              color: sel ? AppColors.secondary : AppColors.textSecondaryLight))));
      }).toList()),
      const SizedBox(height: 20),
      Text(isAr ? 'السنة الدراسية' : 'Year', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 15)),
      const SizedBox(height: 10),
      Row(children: List.generate(7, (i) {
        final y = i + 1; final sel = _year == y;
        return Expanded(child: GestureDetector(onTap: () => setState(() => _year = y),
          child: AnimatedContainer(duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 4), padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(color: sel ? AppColors.secondary : AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: sel ? AppColors.secondary : AppColors.dividerLight)),
            child: Text('$y', textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700,
                color: sel ? Colors.white : AppColors.textPrimaryLight)))));
      })),
      const SizedBox(height: 20),
      Text(isAr ? 'نوع الجامعة' : 'University Type', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 15)),
      const SizedBox(height: 10),
      Row(children: [('public','حكومية','Public'),('private','خاصة','Private'),('national','أهلية','National')].map((t) {
        final sel = _uniType == t.$1;
        return Expanded(child: GestureDetector(onTap: () => setState(() => _uniType = t.$1),
          child: AnimatedContainer(duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 6), padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: sel ? AppColors.secondary.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: sel ? AppColors.secondary : AppColors.dividerLight, width: sel ? 2 : 1)),
            child: Text(isAr ? t.$2 : t.$3, textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 13,
                color: sel ? AppColors.secondary : AppColors.textSecondaryLight)))));
      }).toList()),
      const SizedBox(height: 32),
      CustomButton(label: isAr ? 'التالي' : 'Next', onTap: () { if (_faculty != null) setState(() => _step = 2); else CustomSnackBar.show(message: isAr ? 'اختر كليتك' : 'Select your faculty', type: SnackBarType.warning); }, useGradient: true),
    ]),
  );

  Widget _step3(bool isAr) {
    final filtered = _universities.where((u) => u.toLowerCase().contains(_filter.toLowerCase())).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Text(isAr ? 'الجامعة' : 'University', style: const TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w700, fontSize: 22))),
        const SizedBox(height: 20),
        CustomTextField(controller: _searchCtrl, hint: isAr ? 'ابحث عن جامعتك...' : 'Search university...', prefixIcon: Icons.search, onChanged: (v) => setState(() => _filter = v)),
        const SizedBox(height: 12),
        Container(height: 240, decoration: BoxDecoration(border: Border.all(color: AppColors.dividerLight), borderRadius: BorderRadius.circular(14)),
          child: ListView.builder(itemCount: filtered.length, itemBuilder: (_, i) {
            final u = filtered[i]; final sel = _uniName == u;
            return ListTile(
              title: Text(u, style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: sel ? FontWeight.w700 : FontWeight.w400, color: sel ? AppColors.secondary : AppColors.textPrimaryLight)),
              trailing: sel ? const Icon(Icons.check_circle_rounded, color: AppColors.secondary, size: 18) : null,
              onTap: () => setState(() => _uniName = u));
          })),
        const SizedBox(height: 32),
        CustomButton(label: isAr ? 'إنهاء' : 'Finish', onTap: () { if (_uniName.isEmpty) { CustomSnackBar.show(message: isAr ? 'اختر جامعتك' : 'Select university', type: SnackBarType.warning); return; } _submit(); }, isLoading: _loading, useGradient: true),
        const SizedBox(height: 16),
      ]),
    );
  }
}
