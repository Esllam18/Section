// lib/features/home/widgets/home_recent_orders.dart
import 'package:flutter/material.dart';
import 'package:section/core/constants/app_colors.dart';
import 'package:section/features/home/data/models/home_summary_model.dart';

class HomeRecentOrders extends StatelessWidget {
  final List<RecentOrderSummary> orders;
  final bool isAr;

  const HomeRecentOrders({
    super.key,
    required this.orders,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: isAr ? 'آخر طلباتي' : 'Recent Orders',
          actionLabel: isAr ? 'الكل' : 'See all',
          onTap: () {}, // wired Day 5
        ),
        const SizedBox(height: 10),
        ...orders.map((o) => _OrderRow(order: o, isAr: isAr, isDark: isDark)),
      ],
    );
  }
}

class _OrderRow extends StatelessWidget {
  final RecentOrderSummary order;
  final bool isAr;
  final bool isDark;

  const _OrderRow({
    required this.order,
    required this.isAr,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final (color, label) = _statusStyle(order.status, isAr);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.shopping_bag_outlined,
                size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${order.orderNumber}',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '${order.total.toStringAsFixed(0)} EGP',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  (Color, String) _statusStyle(String status, bool isAr) => switch (status) {
        'pending'   => (AppColors.warning,  isAr ? 'قيد الانتظار' : 'Pending'),
        'confirmed' => (AppColors.info,     isAr ? 'تم التأكيد'   : 'Confirmed'),
        'preparing' => (AppColors.secondary,isAr ? 'جاري التحضير' : 'Preparing'),
        'shipped'   => (AppColors.primary,  isAr ? 'تم الشحن'     : 'Shipped'),
        'delivered' => (AppColors.success,  isAr ? 'تم التوصيل'   : 'Delivered'),
        'cancelled' => (AppColors.error,    isAr ? 'ملغي'          : 'Cancelled'),
        _           => (AppColors.textSecondaryLight, status),
      };
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onTap;

  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionLabel,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
