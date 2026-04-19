// lib/features/home/data/models/home_summary_model.dart

class RecentOrderSummary {
  final String id;
  final String orderNumber;
  final String status;
  final double total;
  final DateTime createdAt;

  const RecentOrderSummary({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.total,
    required this.createdAt,
  });

  factory RecentOrderSummary.fromJson(Map<String, dynamic> j) =>
      RecentOrderSummary(
        id: j['id'] as String,
        orderNumber: j['order_number'] as String? ?? '',
        status: j['status'] as String? ?? 'pending',
        total: (j['total'] as num?)?.toDouble() ?? 0,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}

class RecentPostSummary {
  final String id;
  final String title;
  final String postType;
  final int upvoteCount;
  final int commentCount;
  final DateTime createdAt;

  const RecentPostSummary({
    required this.id,
    required this.title,
    required this.postType,
    required this.upvoteCount,
    required this.commentCount,
    required this.createdAt,
  });

  factory RecentPostSummary.fromJson(Map<String, dynamic> j) =>
      RecentPostSummary(
        id: j['id'] as String,
        title: j['title'] as String? ?? '',
        postType: j['post_type'] as String? ?? 'discussion',
        upvoteCount: j['upvote_count'] as int? ?? 0,
        commentCount: j['comment_count'] as int? ?? 0,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}

class HomeSummaryModel {
  final String fullName;
  final String faculty;
  final int academicYear;
  final bool isProfileComplete;
  final int cartCount;
  final int unreadNotifications;
  final List<RecentOrderSummary> recentOrders;
  final List<RecentPostSummary> recentPosts;
  final int subjectCount;
  final int resourceCount;

  const HomeSummaryModel({
    required this.fullName,
    required this.faculty,
    required this.academicYear,
    required this.isProfileComplete,
    required this.cartCount,
    required this.unreadNotifications,
    required this.recentOrders,
    required this.recentPosts,
    required this.subjectCount,
    required this.resourceCount,
  });

  bool get hasIncompleteProfile => !isProfileComplete;
  bool get hasPendingOrders =>
      recentOrders.any((o) => o.status == 'pending' || o.status == 'confirmed');
}
