// lib/features/study/presentation/screens/study_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:section/core/constants/app_colors.dart';
import 'package:section/core/constants/app_sizes.dart';
import 'package:section/core/services/supabase_service.dart';
import 'package:section/core/widgets/error_state_widget.dart';
import 'package:section/core/widgets/shimmer_widget.dart';
import 'package:section/features/study/data/repositories/study_repository.dart';
import 'package:section/features/study/presentation/cubit/study_cubit.dart';
import 'package:section/features/study/presentation/cubit/study_state.dart';
import 'package:section/features/study/presentation/screens/subject_detail_screen.dart';

class StudyScreen extends StatelessWidget {
  const StudyScreen({super.key});
  @override Widget build(BuildContext context) => BlocProvider(
    create: (_) => StudyCubit(StudyRepository()),
    child: const _StudyView(),
  );
}

class _StudyView extends StatefulWidget {
  const _StudyView();
  @override State<_StudyView> createState() => _StudyViewState();
}

class _StudyViewState extends State<_StudyView> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = SupabaseService.currentUserId;
    String faculty = 'medicine';
    if (uid != null) {
      final p = await SupabaseService.client.from('profiles').select('faculty').eq('id', uid).maybeSingle();
      faculty = p?['faculty'] as String? ?? 'medicine';
    }
    if (mounted) context.read<StudyCubit>().init(faculty);
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return BlocBuilder<StudyCubit, StudyState>(
      builder: (ctx, state) => Scaffold(
        appBar: AppBar(
          title: Text(isAr ? 'الدراسة' : 'Study',
            style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 18)),
        ),
        body: Column(children: [
          // Year chips
          SizedBox(height: 48, child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            children: [
              _yearChip(ctx, null, isAr ? 'الكل' : 'All', state.selectedYear == null),
              ...List.generate(7, (i) => _yearChip(ctx, i+1, isAr ? 'س ${i+1}' : 'Y${i+1}', state.selectedYear == i+1)),
            ])),
          Expanded(child: switch(state.status) {
            StudyStatus.loading => GridView.builder(padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,childAspectRatio:1.2,crossAxisSpacing:12,mainAxisSpacing:12),
              itemCount: 8, itemBuilder: (_,__) => const ShimmerWidget(height: 100, borderRadius: 14)),
            StudyStatus.error => ErrorStateWidget(message: state.error ?? 'Error', onRetry: _load),
            _ => state.filtered.isEmpty
                ? Center(child: Text(isAr ? 'لا توجد مواد' : 'No subjects', style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondaryLight)))
                : RefreshIndicator(color: AppColors.secondary, onRefresh: _load,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,childAspectRatio:1.25,crossAxisSpacing:12,mainAxisSpacing:12),
                      itemCount: state.filtered.length,
                      itemBuilder: (_, i) {
                        final s = state.filtered[i];
                        final colors = [AppColors.primary, AppColors.secondary, const Color(0xFF7C4DFF), AppColors.success, const Color(0xFFFF5252), const Color(0xFF00BCD4)];
                        final c = colors[s.id.hashCode.abs() % colors.length];
                        return GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SubjectDetailScreen(subject: s))),
                          child: Container(padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: c.withOpacity(0.09), borderRadius: BorderRadius.circular(14), border: Border.all(color: c.withOpacity(0.25))),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                                  child: Icon(Icons.menu_book_rounded, color: c, size: 18)),
                                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                                  child: Text('Y${s.academicYear}', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700, color: c))),
                              ]),
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(s.localizedName(isAr), maxLines: 2, overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 13)),
                                Row(children: [Icon(Icons.folder_outlined, size: 12, color: c), const SizedBox(width: 3),
                                  Text('${s.resourceCount} ${isAr ? "مصدر" : "resources"}',
                                    style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: c))]),
                              ]),
                            ])),
                        );
                      })),
          }),
        ]),
      ),
    );
  }

  Widget _yearChip(BuildContext ctx, int? year, String label, bool selected) =>
    GestureDetector(onTap: () => ctx.read<StudyCubit>().filterYear(year),
      child: AnimatedContainer(duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.secondary : AppColors.dividerLight)),
        child: Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 13,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          color: selected ? Colors.white : AppColors.textSecondaryLight))));
}
