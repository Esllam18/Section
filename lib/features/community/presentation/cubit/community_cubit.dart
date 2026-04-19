import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:section/features/community/data/repositories/community_repository.dart';
import 'community_state.dart';
class CommunityCubit extends Cubit<CommunityState> {
  final CommunityRepository _r; String? _faculty;
  CommunityCubit(this._r) : super(const CommunityState());
  Future<void> init({String? faculty}) async { _faculty = faculty; await load(); }
  Future<void> load() async {
    emit(state.copyWith(status:CommunityStatus.loading,page:0));
    try {
      final p = await _r.getPosts(faculty: state.tabIndex==1?_faculty:null);
      emit(state.copyWith(status:CommunityStatus.loaded,posts:p,page:1,hasMore:p.length==20));
    } catch(e) { emit(state.copyWith(status:CommunityStatus.error,error:e.toString())); }
  }
  Future<void> loadMore() async {
    if (!state.hasMore||state.status==CommunityStatus.loadingMore) return;
    emit(state.copyWith(status:CommunityStatus.loadingMore));
    try {
      final more = await _r.getPosts(faculty:state.tabIndex==1?_faculty:null,page:state.page);
      emit(state.copyWith(status:CommunityStatus.loaded,posts:[...state.posts,...more],page:state.page+1,hasMore:more.length==20));
    } catch(_) { emit(state.copyWith(status:CommunityStatus.loaded)); }
  }
  Future<void> switchTab(int i) async { if(i==state.tabIndex) return; emit(state.copyWith(tabIndex:i)); await load(); }
  void toggleUpvote(String id) {
    final posts = state.posts.map((p) { if(p.id!=id) return p; final was=p.isUpvotedByMe; return p.copyWith(upvoteCount:was?p.upvoteCount-1:p.upvoteCount+1,isUpvotedByMe:!was); }).toList();
    emit(state.copyWith(posts:posts));
    _r.toggleUpvote(id).catchError((_)=>load());
  }
  void addPost(post) => emit(state.copyWith(posts:[post,...state.posts]));
}
