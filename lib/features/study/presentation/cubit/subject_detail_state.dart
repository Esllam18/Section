import 'package:equatable/equatable.dart';
import 'package:section/features/study/data/models/resource_model.dart';
enum ResourceStatus { initial, loading, loaded, error }
class SubjectDetailState extends Equatable {
  final ResourceStatus status; final List<ResourceModel> resources; final String tab; final String? error;
  const SubjectDetailState({this.status=ResourceStatus.initial,this.resources=const[],this.tab='pdf',this.error});
  SubjectDetailState copyWith({ResourceStatus? status,List<ResourceModel>? resources,String? tab,String? error}) =>
    SubjectDetailState(status:status??this.status,resources:resources??this.resources,tab:tab??this.tab,error:error);
  @override List<Object?> get props => [status,resources,tab,error];
}
