// lib/features/study/presentation/screens/subject_detail_screen.dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:section/core/constants/app_colors.dart';
import 'package:section/core/services/navigation/navigation.dart';
import 'package:section/core/widgets/custom_button.dart';
import 'package:section/core/widgets/custom_snackbar.dart';
import 'package:section/core/widgets/custom_text_field.dart';
import 'package:section/core/widgets/empty_state_widget.dart';
import 'package:section/core/widgets/error_state_widget.dart';
import 'package:section/core/widgets/shimmer_widget.dart';
import 'package:section/features/study/data/models/subject_model.dart';
import 'package:section/features/study/data/repositories/study_repository.dart';
import 'package:section/features/study/presentation/cubit/subject_detail_cubit.dart';
import 'package:section/features/study/presentation/cubit/subject_detail_state.dart';

class SubjectDetailScreen extends StatelessWidget {
  final SubjectModel subject;
  const SubjectDetailScreen({super.key, required this.subject});
  @override Widget build(BuildContext context) => BlocProvider(
    create: (_) => SubjectDetailCubit(StudyRepository())..init(subject.id),
    child: _SubjectDetailView(subject: subject),
  );
}

class _SubjectDetailView extends StatefulWidget {
  final SubjectModel subject;
  const _SubjectDetailView({required this.subject});
  @override State<_SubjectDetailView> createState() => _SubjectDetailViewState();
}

class _SubjectDetailViewState extends State<_SubjectDetailView> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  static const _tabs = [
    ('pdf','PDFs',Icons.picture_as_pdf_rounded,AppColors.error),
    ('book','Books',Icons.menu_book_rounded,AppColors.primary),
    ('note','Notes',Icons.note_outlined,Color(0xFF7C4DFF)),
    ('exam','Exams',Icons.assignment_outlined,Color(0xFFFFAB00)),
    ('review','Reviews',Icons.rate_review_outlined,AppColors.secondary),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _tabCtrl.addListener(() { if (!_tabCtrl.indexIsChanging) context.read<SubjectDetailCubit>().loadResources(tab: _tabs[_tabCtrl.index].$1); });
  }
  @override void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: Navigation.back),
        title: Text(widget.subject.localizedName(isAr), style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
        bottom: TabBar(controller: _tabCtrl, isScrollable: true,
          tabs: _tabs.map((t) => Tab(child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(t.$3, size: 15, color: t.$4), const SizedBox(width: 5), Text(t.$2)]))).toList()),
      ),
      body: BlocBuilder<SubjectDetailCubit, SubjectDetailState>(
        builder: (ctx, state) => switch(state.status) {
          ResourceStatus.loading => ListView.builder(padding: const EdgeInsets.all(14), itemCount: 5,
            itemBuilder: (_,__) => const Padding(padding: EdgeInsets.only(bottom: 10), child: ShimmerWidget(height: 76, borderRadius: 12))),
          ResourceStatus.error => ErrorStateWidget(message: state.error ?? 'Error', onRetry: () => ctx.read<SubjectDetailCubit>().loadResources()),
          _ => state.resources.isEmpty
              ? EmptyStateWidget(title: isAr ? 'لا توجد مصادر بعد' : 'No resources yet', subtitle: isAr ? 'كن أول من يضيف!' : 'Be the first to upload!',
                  actionLabel: isAr ? 'رفع' : 'Upload', onAction: () => _showUpload(ctx, isAr))
              : RefreshIndicator(color: AppColors.secondary, onRefresh: () => ctx.read<SubjectDetailCubit>().loadResources(),
                  child: ListView.builder(padding: const EdgeInsets.all(14), itemCount: state.resources.length,
                    itemBuilder: (_, i) {
                      final r = state.resources[i];
                      return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? AppColors.dividerDark : AppColors.dividerLight)),
                        child: Row(children: [
                          Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: r.color.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
                            child: Icon(r.icon, color: r.color, size: 20)),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(r.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 13)),
                            Row(children: [
                              const Icon(Icons.person_outline, size: 12, color: AppColors.textSecondaryLight), const SizedBox(width: 3),
                              Text(r.uploaderName ?? '?', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textSecondaryLight)),
                              const SizedBox(width: 10),
                              const Icon(Icons.download_outlined, size: 12, color: AppColors.textSecondaryLight), const SizedBox(width: 3),
                              Text('${r.downloadCount}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textSecondaryLight)),
                            ]),
                          ])),
                          GestureDetector(onTap: () async {
                            if (r.fileUrl != null) {
                              final uri = Uri.parse(r.fileUrl!);
                              if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
                            }
                          }, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.download_rounded, color: Colors.white, size: 18))),
                        ]));
                    })),
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        onPressed: () => _showUpload(context, isAr),
        child: const Icon(Icons.upload_rounded, color: Colors.white),
      ),
    );
  }

  void _showUpload(BuildContext ctx, bool isAr) {
    showModalBottomSheet(context: ctx, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _UploadSheet(subjectId: widget.subject.id, isAr: isAr, onUploaded: (r) => ctx.read<SubjectDetailCubit>().addResource(r)));
  }
}

class _UploadSheet extends StatefulWidget {
  final String subjectId; final bool isAr; final Function(dynamic) onUploaded;
  const _UploadSheet({required this.subjectId, required this.isAr, required this.onUploaded});
  @override State<_UploadSheet> createState() => _UploadSheetState();
}

class _UploadSheetState extends State<_UploadSheet> {
  final _titleCtrl = TextEditingController();
  String _type = 'pdf'; File? _file; String? _fileName; bool _loading = false;

  @override void dispose() { _titleCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isAr;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.dividerLight, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 14),
        Text(isAr ? 'رفع مصدر' : 'Upload Resource', style: const TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w700, fontSize: 18)),
        const SizedBox(height: 14),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
          ('pdf','PDF',AppColors.error),('book','Book',AppColors.primary),
          ('note','Note',Color(0xFF7C4DFF)),('exam','Exam',Color(0xFFFFAB00)),
          ('review','Review',AppColors.secondary),
        ].map((t) {
          final sel = _type == t.$1;
          return GestureDetector(onTap: () => setState(() => _type = t.$1),
            child: AnimatedContainer(duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(color: sel ? t.$3.withOpacity(0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? t.$3 : AppColors.dividerLight, width: sel ? 2 : 1)),
              child: Text(t.$2, style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: sel ? t.$3 : AppColors.textSecondaryLight, fontWeight: sel ? FontWeight.w700 : FontWeight.w400))));
        }).toList())),
        const SizedBox(height: 14),
        CustomTextField(controller: _titleCtrl, hint: isAr ? 'عنوان المصدر' : 'Resource title', prefixIcon: Icons.title),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () async {
            final r = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf','doc','docx']);
            if (r != null && r.files.isNotEmpty) setState(() { _file = File(r.files.single.path!); _fileName = r.files.single.name; });
          },
          child: Container(width: double.infinity, padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: _file != null ? AppColors.secondary.withOpacity(0.07) : AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12), border: Border.all(color: _file != null ? AppColors.secondary : AppColors.dividerLight)),
            child: Column(children: [
              Icon(_file != null ? Icons.check_circle_outline : Icons.upload_file_rounded,
                color: _file != null ? AppColors.secondary : AppColors.textSecondaryLight, size: 26),
              const SizedBox(height: 6),
              Text(_fileName ?? (isAr ? 'اضغط لاختيار ملف' : 'Tap to select file'),
                style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: _file != null ? AppColors.secondary : AppColors.textSecondaryLight)),
            ])),
        ),
        if (_loading) ...[const SizedBox(height: 8), const LinearProgressIndicator(color: AppColors.secondary, backgroundColor: AppColors.dividerLight)],
        const SizedBox(height: 16),
        CustomButton(label: isAr ? 'رفع' : 'Upload', onTap: () async {
          if (_titleCtrl.text.trim().isEmpty) { CustomSnackBar.show(message: isAr ? 'أدخل العنوان' : 'Enter title', type: SnackBarType.warning); return; }
          if (_file == null) { CustomSnackBar.show(message: isAr ? 'اختر ملفاً' : 'Select a file', type: SnackBarType.warning); return; }
          setState(() => _loading = true);
          try {
            final r = await StudyRepository().uploadResource(subjectId: widget.subjectId, title: _titleCtrl.text.trim(), type: _type, file: _file);
            if (mounted) { Navigator.pop(context); widget.onUploaded(r); CustomSnackBar.show(message: isAr ? 'تم الرفع!' : 'Uploaded!', type: SnackBarType.success); }
          } catch (e) { if (mounted) { setState(() => _loading = false); CustomSnackBar.show(message: e.toString(), type: SnackBarType.error); } }
        }, isLoading: _loading, useGradient: true),
      ])),
    );
  }
}
