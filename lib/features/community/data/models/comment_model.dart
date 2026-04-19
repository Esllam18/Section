class CommentModel {
  final String id, postId, userId, body;
  final String? userFullName, userAvatarUrl, parentId;
  final DateTime createdAt;
  const CommentModel({required this.id,required this.postId,required this.userId,
    required this.body,this.userFullName,this.userAvatarUrl,this.parentId,required this.createdAt});
  factory CommentModel.fromJson(Map<String,dynamic> j) {
    final p = j['profiles'] as Map<String,dynamic>?;
    return CommentModel(id:j['id'],postId:j['post_id'],userId:j['user_id'],
      body:j['body']??'',userFullName:p?['full_name'],userAvatarUrl:p?['avatar_url'],
      parentId:j['parent_id'],createdAt:DateTime.parse(j['created_at']));
  }
}
