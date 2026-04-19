// lib/features/study/presentation/widgets/upload_resource_sheet.dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:section/core/constants/app_colors.dart';
import 'package:section/core/widgets/custom_button.dart';
import 'package:section/core/widgets/custom_snackbar.dart';
import 'package:section/core/widgets/custom_text_field.dart';
import 'package:section/features/study/data/models/resource_model.dart';
import 'package:section/features/study/data/repositories/study_repository.dart';

class UploadResourceSheet extends StatefulWidget {
  final String subjectId;
  final bool isAr;
  final ValueChanged<ResourceModel> onUploaded;

  const UploadResourceSheet({
    super.key,
    required this.subjectId,
    required this.isAr,
    required this.onUploaded,
  });

  static Future<void> show(
    BuildContext context, {
    required String subjectId,
    required bool isAr,
    required ValueChanged<ResourceModel> onUploaded,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UploadResourceSheet(
        subjectId: subjectId,
        isAr: isAr,
        onUploaded: onUploaded,
      ),
    );
  }

  @override
  State<UploadResourceSheet> createState() => _UploadResourceSheetState();
}

class _UploadResourceSheetState extends State<UploadResourceSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _type = 'pdf';
  File? _file;
  bool _loading = false;

  static const _types = [
    ('pdf', 'PDF', Icons.picture_as_pdf_rounded, Color(0xFFD50000)),
    ('book', 'Book', Icons.menu_book_rounded, Color(0xFF1565C0)),
    ('note', 'Note', Icons.note_outlined, Color(0xFF7C4DFF)),
    ('exam', 'Exam', Icons.assignment_outlined, Color(0xFFFFAB00)),
    ('review', 'Review', Icons.rate_review_outlined, Color(0xFF00BCD4)),
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
    );
    if (res != null && res.files.single.path != null) {
      setState(() => _file = File(res.files.single.path!));
    }
  }

  Future<void> _upload() async {
    if (_titleCtrl.text.trim().isEmpty) {
      CustomSnackBar.show(
        message: widget.isAr ? 'العنوان مطلوب' : 'Title is required',
        type: SnackBarType.warning,
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final r = await StudyRepository().uploadResource(
        subjectId: widget.subjectId,
        title: _titleCtrl.text.trim(),
        desc: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        type: _type,
        file: _file,
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onUploaded(r);
        CustomSnackBar.show(
          message: widget.isAr ? 'تم الرفع بنجاح!' : 'Uploaded successfully!',
          type: SnackBarType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        CustomSnackBar.show(message: e.toString(), type: SnackBarType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.dividerLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.isAr ? 'رفع مصدر جديد' : 'Upload Resource',
            style: const TextStyle(
              fontFamily: 'Lora',
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),

          // Type selector
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _types.map((t) {
                final sel = _type == t.$1;
                return GestureDetector(
                  onTap: () => setState(() => _type = t.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel ? t.$4.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sel ? t.$4 : AppColors.dividerLight,
                        width: sel ? 1.5 : 1,
                      ),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(t.$3,
                          size: 14,
                          color: sel ? t.$4 : AppColors.textSecondaryLight),
                      const SizedBox(width: 4),
                      Text(
                        widget.isAr ? _arLabel(t.$1) : t.$2,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                          color: sel ? t.$4 : AppColors.textSecondaryLight,
                        ),
                      ),
                    ]),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // Title field
          CustomTextField(
            controller: _titleCtrl,
            hint: widget.isAr ? 'العنوان *' : 'Title *',
            prefixIcon: Icons.title,
          ),
          const SizedBox(height: 10),

          // Description field
          CustomTextField(
            controller: _descCtrl,
            hint: widget.isAr ? 'وصف (اختياري)' : 'Description (optional)',
            prefixIcon: Icons.notes,
            maxLines: 2,
          ),
          const SizedBox(height: 12),

          // File picker
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: _file != null
                    ? AppColors.success.withOpacity(0.06)
                    : (isDark ? AppColors.cardDark : AppColors.inputFillLight),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _file != null
                      ? AppColors.success
                      : AppColors.dividerLight,
                ),
              ),
              child: Row(children: [
                Icon(
                  _file != null
                      ? Icons.check_circle_outline
                      : Icons.upload_file_rounded,
                  color: _file != null
                      ? AppColors.success
                      : AppColors.textSecondaryLight,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _file != null
                        ? _file!.path.split('/').last
                        : (widget.isAr
                            ? 'اختر ملفاً (PDF، Word، PPT)'
                            : 'Pick file (PDF, Word, PPT)'),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: _file != null
                          ? AppColors.success
                          : AppColors.textSecondaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 18),

          CustomButton(
            label: widget.isAr ? 'رفع' : 'Upload',
            useGradient: true,
            isLoading: _loading,
            onTap: _upload,
          ),
        ],
      ),
    );
  }

  String _arLabel(String type) => switch (type) {
        'pdf' => 'PDF',
        'book' => 'كتاب',
        'note' => 'ملاحظات',
        'exam' => 'امتحان',
        'review' => 'مراجعة',
        _ => type,
      };
}
