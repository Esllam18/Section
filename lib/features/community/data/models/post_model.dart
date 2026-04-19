class PostModel {
  final String id, userId, postType, title, body;
  final String? userFullName, userAvatarUrl, faculty;
  final bool userIsVerified, isUpvotedByMe;
  final int upvoteCount, commentCount;
  final List<String> images;
  final DateTime createdAt;
  const PostModel({required this.id, required this.userId, required this.postType,
    required this.title, required this.body, this.userFullName, this.userAvatarUrl,
    this.faculty, this.userIsVerified=false, this.isUpvotedByMe=false,
    this.upvoteCount=0, this.commentCount=0, this.images=const[], required this.createdAt});
  factory PostModel.fromJson(Map<String,dynamic> j) {
    final p = j['profiles'] as Map<String,dynamic>?;
    return PostModel(id: j['id'], userId: j['user_id'], postType: j['post_type']??'discussion',
      title: j['title']??'', body: j['body']??'',
      userFullName: p?['full_name'], userAvatarUrl: p?['avatar_url'],
      userIsVerified: p?['is_verified']??false, faculty: j['faculty'],
      upvoteCount: j['upvote_count']??0, commentCount: j['comment_count']??0,
      images: (j['images'] as List?)?.cast<String>()??[],
      createdAt: DateTime.parse(j['created_at']));
  }
  PostModel copyWith({int? upvoteCount, bool? isUpvotedByMe}) => PostModel(
    id:id,userId:userId,postType:postType,title:title,body:body,
    userFullName:userFullName,userAvatarUrl:userAvatarUrl,userIsVerified:userIsVerified,
    faculty:faculty,upvoteCount:upvoteCount??this.upvoteCount,commentCount:commentCount,
    images:images,isUpvotedByMe:isUpvotedByMe??this.isUpvotedByMe,createdAt:createdAt);
}
