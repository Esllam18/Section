import 'package:equatable/equatable.dart';
import 'package:section/features/study/data/models/subject_model.dart';
enum StudyStatus { initial, loading, loaded, error }
class StudyState extends Equatable {
  final StudyStatus status; final List<SubjectModel> subjects; final int? selectedYear; final String? error;
  const StudyState({this.status=StudyStatus.initial,this.subjects=const[],this.selectedYear,this.error});
  List<SubjectModel> get filtered => selectedYear==null?subjects:subjects.where((s)=>s.academicYear==selectedYear).toList();
  StudyState copyWith({StudyStatus? status,List<SubjectModel>? subjects,int? selectedYear,bool clearYear=false,String? error}) =>
    StudyState(status:status??this.status,subjects:subjects??this.subjects,selectedYear:clearYear?null:(selectedYear??this.selectedYear),error:error);
  @override List<Object?> get props => [status,subjects,selectedYear,error];
}
