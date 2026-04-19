import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:section/features/study/data/repositories/study_repository.dart';
import 'study_state.dart';
class StudyCubit extends Cubit<StudyState> {
  final StudyRepository _r; String? _faculty;
  StudyCubit(this._r) : super(const StudyState());
  Future<void> init(String faculty) async {
    _faculty = faculty;
    emit(state.copyWith(status:StudyStatus.loading));
    try { emit(state.copyWith(status:StudyStatus.loaded,subjects:await _r.getSubjects(faculty:faculty))); }
    catch(e) { emit(state.copyWith(status:StudyStatus.error,error:e.toString())); }
  }
  Future<void> filterYear(int? year) async {
    if (_faculty==null) return;
    emit(state.copyWith(status:StudyStatus.loading,selectedYear:year,clearYear:year==null));
    try { emit(state.copyWith(status:StudyStatus.loaded,subjects:await _r.getSubjects(faculty:_faculty!,year:year))); }
    catch(e) { emit(state.copyWith(status:StudyStatus.error,error:e.toString())); }
  }
}
