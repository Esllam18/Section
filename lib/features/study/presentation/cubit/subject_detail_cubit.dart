import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:section/features/study/data/repositories/study_repository.dart';
import 'subject_detail_state.dart';
class SubjectDetailCubit extends Cubit<SubjectDetailState> {
  final StudyRepository _r; late String _subjectId;
  SubjectDetailCubit(this._r) : super(const SubjectDetailState());
  Future<void> init(String id) async { _subjectId = id; await loadResources(); }
  Future<void> loadResources({String? tab}) async {
    final t = tab ?? state.tab;
    emit(state.copyWith(status:ResourceStatus.loading,tab:t));
    try { emit(state.copyWith(status:ResourceStatus.loaded,resources:await _r.getResources(subjectId:_subjectId,type:t))); }
    catch(e) { emit(state.copyWith(status:ResourceStatus.error,error:e.toString())); }
  }
  void addResource(r) { if(r.resourceType==state.tab) emit(state.copyWith(resources:[r,...state.resources])); }
}
