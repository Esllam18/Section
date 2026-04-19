// lib/features/cart/presentation/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:section/core/constants/app_colors.dart';
import 'package:section/core/constants/app_sizes.dart';
import 'package:section/core/services/navigation/navigation.dart';
import 'package:section/core/widgets/cached_image_widget.dart';
import 'package:section/core/widgets/custom_button.dart';
import 'package:section/core/widgets/empty_state_widget.dart';
import 'package:section/core/widgets/error_state_widget.dart';
import 'package:section/core/widgets/shimmer_widget.dart';
import 'package:section/features/cart/data/repositories/cart_repository.dart';
import 'package:section/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:section/features/checkout/presentation/screens/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => CartCubit(CartRepository())..load(),
    child: const _CartView(),
  );
}

class _CartView extends StatelessWidget {
  const _CartView();

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: Navigation.back),
        title: Text(isAr ? 'سلة التسوق' : 'Shopping Cart',
            style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
        actions: [
          BlocBuilder<CartCubit, CartState>(
            builder: (ctx, s) => s.items.isNotEmpty
                ? TextButton(
                    onPressed: () => ctx.read<CartCubit>().clear(),
                    child: Text(isAr ? 'مسح الكل' : 'Clear',
                        style: const TextStyle(fontFamily: 'Cairo', color: AppColors.error)))
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (ctx, state) {
          if (state.status == CartStatus.loading) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 3,
              itemBuilder: (_, __) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: ShimmerWidget(height: 100, borderRadius: 12),
              ),
            );
          }
          if (state.status == CartStatus.error) {
            return ErrorStateWidget(
                message: state.error ?? '',
                onRetry: () => ctx.read<CartCubit>().load());
          }
          if (state.items.isEmpty) {
            return EmptyStateWidget(
              title: isAr ? 'السلة فارغة' : 'Cart is Empty',
              subtitle: isAr ? 'أضف منتجات من المتجر' : 'Add products from the store',
            );
          }
          return Column(children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.items.length,
                itemBuilder: (_, i) {
                  final item = state.items[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isDark
                          ? []
                          : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                    ),
                    child: Row(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedImageWidget(
                            imageUrl: item.productImage, width: 72, height: 72),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(item.localizedName(isAr),
                            style: const TextStyle(fontFamily: 'Cairo',
                                fontWeight: FontWeight.w700, fontSize: 14),
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 6),
                          Row(children: [
                            if (item.discountPrice != null)
                              Text('${item.price.toStringAsFixed(0)} ج',
                                style: const TextStyle(fontFamily: 'Cairo', fontSize: 11,
                                  color: AppColors.textSecondaryLight,
                                  decoration: TextDecoration.lineThrough)),
                            const SizedBox(width: 6),
                            Text('${item.effectivePrice.toStringAsFixed(0)} ج',
                              style: const TextStyle(fontFamily: 'Cairo',
                                fontWeight: FontWeight.w700, fontSize: 14,
                                color: AppColors.primary)),
                          ]),
                        ]),
                      ),
                      Column(children: [
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          _QtyBtn(
                            icon: Icons.remove,
                            onTap: () => ctx.read<CartCubit>().updateQty(item.id, item.quantity - 1),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text('${item.quantity}',
                              style: const TextStyle(fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w700, fontSize: 15)),
                          ),
                          _QtyBtn(
                            icon: Icons.add,
                            onTap: () => ctx.read<CartCubit>().updateQty(item.id, item.quantity + 1),
                          ),
                        ]),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => ctx.read<CartCubit>().remove(item.id),
                          child: const Icon(Icons.delete_outline_rounded,
                              color: AppColors.error, size: 20)),
                      ]),
                    ]),
                  );
                },
              ),
            ),
            // ── Summary bar ─────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                border: Border(top: BorderSide(color: AppColors.dividerLight, width: 0.5)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05),
                      blurRadius: 8, offset: const Offset(0, -4))
                ],
              ),
              child: SafeArea(
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(isAr ? 'المجموع' : 'Subtotal',
                      style: const TextStyle(fontFamily: 'Cairo',
                          fontWeight: FontWeight.w700, fontSize: 15)),
                    Text('${state.total.toStringAsFixed(0)} ج',
                      style: const TextStyle(fontFamily: 'Cairo',
                          fontWeight: FontWeight.w700, fontSize: 20,
                          color: AppColors.primary)),
                  ]),
                  const SizedBox(height: 4),
                  Text(isAr ? '+ 50 ج رسوم شحن' : '+ 50 EGP shipping fee',
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 12,
                        color: AppColors.textSecondaryLight)),
                  const SizedBox(height: 14),
                  CustomButton(
                    label: isAr ? 'إتمام الطلب' : 'Proceed to Checkout',
                    onTap: () => Navigation.to(CheckoutScreen(
                      items: state.items,
                      total: state.total,
                    )),
                    useGradient: true,
                    icon: Icons.shopping_cart_checkout_rounded,
                  ),
                ]),
              ),
            ),
          ]);
        },
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 16, color: AppColors.primary),
    ),
  );
}
