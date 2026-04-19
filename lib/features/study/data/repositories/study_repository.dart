import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:section/core/services/supabase_service.dart';
import 'package:section/features/study/data/models/resource_model.dart';
import 'package:section/features/study/data/models/subject_model.dart';

class StudyRepository {
  final _db = Supabase.instance.client;

  Future<List<SubjectModel>> getSubjects({required String faculty, int? year}) async {
    // Filters first, then order
    var q = _db.from('subjects').select().eq('faculty', faculty);
    if (year != null) q = q.eq('academic_year', year);
    final data = await q.order('academic_year');
    return (data as List<dynamic>).map((e) => SubjectModel.fromJson(e as Map<String,dynamic>)).toList();
  }

  Future<List<ResourceModel>> getResources(
      {required String subjectId, String? type}) async {
    // Filters first, then order
    var q = _db
        .from('resources')
        .select('*,profiles(id,full_name)')
        .eq('subject_id', subjectId);
    if (type != null) q = q.eq('resource_type', type);
    final data = await q.order('created_at', ascending: false);
    return (data as List<dynamic>).map((e) => ResourceModel.fromJson(e as Map<String,dynamic>)).toList();
  }

  Future<ResourceModel> uploadResource({
    required String subjectId,
    required String title,
    String? desc,
    required String type,
    File? file,
    String? url,
  }) async {
    final uid = SupabaseService.currentUserId!;
    String? fileUrl = url;
    if (file != null) {
      final fn = '${uid}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      await SupabaseService.storage
          .from('study-resources')
          .upload(fn, file, fileOptions: const FileOptions(upsert: true));
      fileUrl = SupabaseService.storage.from('study-resources').getPublicUrl(fn);
    }
    final d = await _db
        .from('resources')
        .insert({
          'subject_id': subjectId,
          'user_id': uid,
          'title': title,
          'description': desc,
          'resource_type': type,
          'file_url': fileUrl,
        })
        .select('*,profiles(id,full_name)')
        .single();
    return ResourceModel.fromJson(d);
  }

  Future<void> incrementDownload(String id) async {
    await _db.rpc('increment_download_count', params: {'resource_id': id});
  }
}
