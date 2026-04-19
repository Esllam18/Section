// lib/features/store/presentation/screens/orders_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:section/core/constants/app_colors.dart';
import 'package:section/core/localization/locale_cubit.dart';
import 'package:section/core/localization/locale_state.dart';
import 'package:section/core/services/navigation/navigation.dart';
import 'package:section/core/widgets/empty_state_widget.dart';
import 'package:section/core/widgets/loading_widget.dart';
import 'package:section/features/store/data/models/order_model.dart';
import 'package:section/features/store/data/repositories/order_repository.dart';
import 'package:timeago/timeago.dart' as timeago;

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<OrderModel> _orders = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try { _orders = await OrderRepository().getOrders(); } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (_, locale) {
        final isAr = locale.locale.languageCode == 'ar';
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: Navigation.back),
            title: Text(isAr ? 'طلباتي' : 'My Orders',
                style: const TextStyle(
                    fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
          ),
          body: _loading
              ? const LoadingWidget()
              : _orders.isEmpty
                  ? EmptyStateWidget(
                      title: isAr ? 'لا توجد طلبات' : 'No orders yet',
                      subtitle: isAr
                          ? 'ابدأ التسوق الآن!'
                          : 'Start shopping now!')
                  : RefreshIndicator(
                      color: AppColors.secondary,
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(14),
                        itemCount: _orders.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) =>
                            _OrderCard(order: _orders[i], isAr: isAr),
                      ),
                    ),
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final bool isAr;
  const _OrderCard({required this.order, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (statusColor, statusLabel) = _statusStyle(order.status, isAr);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text('#${order.orderNumber}',
                style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w700,
                    fontSize: 14)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20)),
            child: Text(statusLabel,
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor)),
          ),
        ]),
        const SizedBox(height: 6),
        Text(
          timeago.format(order.createdAt,
              locale: isAr ? 'ar' : 'en'),
          style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: AppColors.textSecondaryLight),
        ),
        const Divider(height: 16),
        ...order.items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${item.localizedName(isAr)} × ${item.quantity}',
                  style: const TextStyle(
                      fontFamily: 'Cairo', fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text('${item.totalPrice.toStringAsFixed(0)} EGP',
                  style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        )),
        const Divider(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(isAr ? 'الإجمالي' : 'Total',
              style: const TextStyle(
                  fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
          Text('${order.total.toStringAsFixed(0)} EGP',
              style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary)),
        ]),
      ]),
    );
  }

  (Color, String) _statusStyle(String s, bool isAr) => switch (s) {
        'pending'   => (AppColors.warning,   isAr ? 'قيد الانتظار' : 'Pending'),
        'confirmed' => (AppColors.info,      isAr ? 'مؤكد'         : 'Confirmed'),
        'preparing' => (AppColors.secondary, isAr ? 'جاري التحضير' : 'Preparing'),
        'shipped'   => (AppColors.primary,   isAr ? 'تم الشحن'     : 'Shipped'),
        'delivered' => (AppColors.success,   isAr ? 'تم التوصيل'   : 'Delivered'),
        'cancelled' => (AppColors.error,     isAr ? 'ملغي'          : 'Cancelled'),
        _           => (AppColors.textSecondaryLight, s),
      };
}
