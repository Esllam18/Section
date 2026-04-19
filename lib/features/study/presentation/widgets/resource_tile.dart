// lib/features/study/presentation/widgets/resource_tile.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:section/core/constants/app_colors.dart';
import 'package:section/core/widgets/custom_snackbar.dart';
import 'package:section/features/study/data/models/resource_model.dart';
import 'package:section/features/study/data/repositories/study_repository.dart';
import 'package:timeago/timeago.dart' as timeago;

class ResourceTile extends StatefulWidget {
  final ResourceModel resource;
  final bool isAr;

  const ResourceTile({super.key, required this.resource, required this.isAr});

  @override
  State<ResourceTile> createState() => _ResourceTileState();
}

class _ResourceTileState extends State<ResourceTile> {
  bool _downloading = false;

  Future<void> _open() async {
    final r = widget.resource;
    if (!r.hasFile) {
      CustomSnackBar.show(
        message: widget.isAr ? 'لا يوجد ملف مرفق' : 'No file attached',
        type: SnackBarType.warning,
      );
      return;
    }
    setState(() => _downloading = true);
    try {
      await StudyRepository().incrementDownload(r.id);
      final uri = Uri.parse(r.fileUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (mounted) {
        CustomSnackBar.show(
          message: widget.isAr ? 'فشل فتح الملف' : 'Could not open file',
          type: SnackBarType.error,
        );
      }
    }
    if (mounted) setState(() => _downloading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final r = widget.resource;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: r.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(r.icon, color: r.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.title,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(children: [
                  Text(
                    r.uploaderName ?? (widget.isAr ? 'مجهول' : 'Unknown'),
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  const Text(' · ',
                      style: TextStyle(color: AppColors.textSecondaryLight)),
                  Text(
                    timeago.format(r.createdAt,
                        locale: widget.isAr ? 'ar' : 'en'),
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ]),
                if (r.downloadCount > 0) ...[
                  const SizedBox(height: 2),
                  Row(children: [
                    Icon(Icons.download_outlined,
                        size: 11, color: AppColors.textSecondaryLight),
                    const SizedBox(width: 3),
                    Text(
                      '${r.downloadCount}',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ]),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: r.hasFile ? _open : null,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: r.hasFile
                    ? r.color.withOpacity(0.1)
                    : AppColors.dividerLight.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _downloading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: r.color,
                      ),
                    )
                  : Icon(
                      r.hasFile
                          ? Icons.open_in_new_rounded
                          : Icons.link_off_rounded,
                      size: 18,
                      color: r.hasFile ? r.color : AppColors.textHintLight,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
