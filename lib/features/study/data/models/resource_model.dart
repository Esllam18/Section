import 'package:flutter/material.dart';
class ResourceModel {
  final String id, subjectId, uploaderId, title, resourceType;
  final String? uploaderName, description, fileUrl;
  final int downloadCount; final DateTime createdAt;
  const ResourceModel({required this.id,required this.subjectId,required this.uploaderId,
    required this.title,required this.resourceType,this.uploaderName,this.description,
    this.fileUrl,this.downloadCount=0,required this.createdAt});
  IconData get icon { switch(resourceType) { case 'book': return Icons.menu_book_rounded; case 'pdf': return Icons.picture_as_pdf_rounded; case 'note': return Icons.note_outlined; case 'exam': return Icons.assignment_outlined; default: return Icons.rate_review_outlined; } }
  bool get hasFile => fileUrl != null && fileUrl!.isNotEmpty;
  Color get color { switch(resourceType) { case 'book': return const Color(0xFF1565C0); case 'pdf': return const Color(0xFFD50000); case 'note': return const Color(0xFF7C4DFF); case 'exam': return const Color(0xFFFFAB00); default: return const Color(0xFF00BCD4); } }
  factory ResourceModel.fromJson(Map<String,dynamic> j) {
    final p = j['profiles'] as Map<String,dynamic>?;
    return ResourceModel(id:j['id'],subjectId:j['subject_id'],uploaderId:j['user_id'],
      title:j['title'],resourceType:j['resource_type']??'pdf',
      uploaderName:p?['full_name'],description:j['description'],
      fileUrl:j['file_url'],downloadCount:j['download_count']??0,
      createdAt:DateTime.parse(j['created_at']));
  }
}
