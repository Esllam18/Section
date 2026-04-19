// lib/features/orders/presentation/screens/orders_screen.dart
import 'package:flutter/material.dart';
import 'package:section/core/constants/app_colors.dart';
import 'package:section/core/services/navigation/navigation.dart';
import 'package:section/core/widgets/empty_state_widget.dart';
import 'package:section/core/widgets/shimmer_widget.dart';
import 'package:section/features/orders/data/models/order_model.dart';
import 'package:section/features/orders/data/repositories/orders_repository.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _repo = OrdersRepository();
  List<OrderModel>? _orders;
  bool _loading = true, _error = false;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = false; });
    try {
      final o = await _repo.getOrders();
      if (mounted) setState(() { _orders = o; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = true; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: Navigation.back),
        title: Text(isAr ? 'طلباتي' : 'My Orders',
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
      ),
      body: _loading
        ? _shimmer()
        : _error
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 12),
              TextButton(onPressed: _load, child: Text(isAr ? 'إعادة المحاولة' : 'Retry',
                style: const TextStyle(fontFamily: 'Cairo', color: AppColors.primary))),
            ]))
          : (_orders?.isEmpty ?? true)
            ? EmptyStateWidget(
                title: isAr ? 'لا توجد طلبات' : 'No Orders Yet',
                subtitle: isAr ? 'ابدأ التسوق من المتجر' : 'Start shopping from the store',
              )
            : RefreshIndicator(
                onRefresh: _load,
                color: AppColors.secondary,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _orders!.length,
                  itemBuilder: (_, i) => _OrderCard(order: _orders![i], isAr: isAr),
                ),
              ),
    );
  }

  Widget _shimmer() => ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: 4,
    itemBuilder: (_, __) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ShimmerWidget(height: 110, borderRadius: 14),
    ),
  );
}

class _OrderCard extends StatelessWidget {
  final OrderModel order; final bool isAr;
  const _OrderCard({required this.order, required this.isAr});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('#${order.orderNumber}',
            style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 14)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: order.statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(order.statusLabel(isAr),
              style: TextStyle(fontFamily: 'Cairo', fontSize: 12,
                fontWeight: FontWeight.w700, color: order.statusColor)),
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondaryLight),
          const SizedBox(width: 4),
          Text(DateFormat('d MMM yyyy', isAr ? 'ar' : 'en').format(order.createdAt),
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondaryLight)),
          const Spacer(),
          Text('${order.total.toStringAsFixed(0)} ج',
            style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700,
              fontSize: 16, color: AppColors.primary)),
        ]),
        if (order.items.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Text('${order.items.length} ${isAr ? 'منتج' : 'item(s)'}',
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondaryLight)),
        ],
      ]),
    );
  }
}
