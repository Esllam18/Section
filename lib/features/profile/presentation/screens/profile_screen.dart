// lib/features/profile/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:section/core/constants/app_colors.dart';
import 'package:section/core/services/navigation/navigation.dart';
import 'package:section/core/services/supabase_service.dart';
import 'package:section/core/widgets/cached_image_widget.dart';
import 'package:section/core/widgets/shimmer_widget.dart';
import 'package:section/features/settings/presentation/screens/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final uid = SupabaseService.currentUserId;
    if (uid == null) return;
    setState(() => _loading = true);
    try {
      final p = await SupabaseService.client
          .from('profiles').select().eq('id', uid).maybeSingle();
      if (mounted) setState(() { _profile = p; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.secondary,
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              systemOverlayStyle: isDark
                  ? SystemUiOverlayStyle.light
                  : SystemUiOverlayStyle.dark,
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => Navigation.to(const SettingsScreen()),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                  child: _loading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : SafeArea(
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            const SizedBox(height: 20),
                            // Avatar
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                              child: ClipOval(
                                child: CachedImageWidget(
                                  imageUrl: _profile?['avatar_url'],
                                  width: 80, height: 80,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _profile?['full_name'] ?? _profile?['email'] ?? '',
                              style: const TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w700,
                                  fontSize: 20, color: Colors.white),
                            ),
                            if (_profile?['faculty'] != null) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _profile!['faculty'].toString().toUpperCase(),
                                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 11,
                                      color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ]),
                        ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _loading
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(children: [
                        ShimmerWidget(height: 80, borderRadius: 12),
                        const SizedBox(height: 12),
                        ShimmerWidget(height: 80, borderRadius: 12),
                      ]),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        // Stats row
                        Row(children: [
                          _StatChip(
                            icon: Icons.school_outlined,
                            label: isAr ? 'السنة' : 'Year',
                            value: _profile?['academic_year']?.toString() ?? '-',
                          ),
                          const SizedBox(width: 12),
                          _StatChip(
                            icon: Icons.location_city_outlined,
                            label: isAr ? 'الجامعة' : 'University',
                            value: _profile?['university_name'] ?? '-',
                            flex: 2,
                          ),
                        ]),
                        const SizedBox(height: 16),
                        // Bio
                        if (_profile?['bio'] != null && _profile!['bio'].toString().isNotEmpty) ...[
                          Text(isAr ? 'نبذة' : 'About',
                            style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 15)),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(_profile!['bio'],
                              style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, height: 1.6)),
                          ),
                          const SizedBox(height: 16),
                        ],
                        // Info tiles
                        Text(isAr ? 'المعلومات' : 'Information',
                          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 15)),
                        const SizedBox(height: 10),
                        _InfoTile(icon: Icons.email_outlined,
                          label: isAr ? 'البريد الإلكتروني' : 'Email',
                          value: _profile?['email'] ?? SupabaseService.currentUser?.email ?? '-'),
                        _InfoTile(icon: Icons.phone_outlined,
                          label: isAr ? 'الهاتف' : 'Phone',
                          value: _profile?['phone'] ?? '-'),
                        _InfoTile(icon: Icons.verified_user_outlined,
                          label: isAr ? 'معرّف الطالب' : 'Student ID',
                          value: _profile?['student_id'] ?? '-'),
                        const SizedBox(height: 80),
                      ]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon; final String label, value; final int flex;
  const _StatChip({required this.icon, required this.label, required this.value, this.flex = 1});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
        ),
        child: Row(children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textSecondaryLight)),
            Text(value, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 13),
              overflow: TextOverflow.ellipsis),
          ])),
        ]),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon; final String label, value;
  const _InfoTile({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textSecondaryLight)),
          Text(value, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14)),
        ])),
      ]),
    );
  }
}
