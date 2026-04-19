import 'package:equatable/equatable.dart';
import 'package:section/features/community/data/models/post_model.dart';
enum CommunityStatus { initial, loading, loaded, loadingMore, error }
class CommunityState extends Equatable {
  final CommunityStatus status; final List<PostModel> posts;
  final int tabIndex; final String? error; final bool hasMore; final int page;
  const CommunityState({this.status=CommunityStatus.initial,this.posts=const[],this.tabIndex=0,this.error,this.hasMore=true,this.page=0});
  CommunityState copyWith({CommunityStatus? status,List<PostModel>? posts,int? tabIndex,String? error,bool? hasMore,int? page}) =>
    CommunityState(status:status??this.status,posts:posts??this.posts,tabIndex:tabIndex??this.tabIndex,error:error,hasMore:hasMore??this.hasMore,page:page??this.page);
  @override List<Object?> get props => [status,posts,tabIndex,error,hasMore,page];
}
