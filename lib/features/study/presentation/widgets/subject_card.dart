// lib/features/study/presentation/widgets/subject_card.dart
import 'package:flutter/material.dart';
import 'package:section/features/study/data/models/subject_model.dart';

class SubjectCard extends StatelessWidget {
  final SubjectModel subject;
  final bool isAr;
  final VoidCallback onTap;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.isAr,
    required this.onTap,
  });

  static const _palette = [
    Color(0xFF1565C0), Color(0xFF00ACC1), Color(0xFF7C4DFF),
    Color(0xFF00C853), Color(0xFFFF5252), Color(0xFFFF6F00),
  ];

  Color get _color => _palette[subject.id.hashCode.abs() % _palette.length];

  @override
  Widget build(BuildContext context) {
    final c = _color;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.withOpacity(0.09),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: c.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.menu_book_rounded, color: c, size: 18),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: c.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isAr ? 'س${subject.academicYear}' : 'Y${subject.academicYear}',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: c,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.localizedName(isAr),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Row(children: [
                  Icon(Icons.folder_outlined, size: 12, color: c),
                  const SizedBox(width: 3),
                  Text(
                    '${subject.resourceCount} ${isAr ? "مصدر" : "resources"}',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10,
                      color: c,
                    ),
                  ),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
