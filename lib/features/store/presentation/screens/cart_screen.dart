// lib/features/store/presentation/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:section/core/constants/app_colors.dart';
import 'package:section/core/constants/app_sizes.dart';
import 'package:section/core/localization/locale_cubit.dart';
import 'package:section/core/localization/locale_state.dart';
import 'package:section/core/services/navigation/navigation.dart';
import 'package:section/core/widgets/cached_image_widget.dart';
import 'package:section/core/widgets/custom_button.dart';
import 'package:section/core/widgets/empty_state_widget.dart';
import 'package:section/core/widgets/loading_widget.dart';
import 'package:section/features/cart/data/models/cart_item_model.dart';
import 'package:section/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:section/features/store/data/repositories/cart_repository.dart';
import 'package:section/features/store/presentation/cubit/cart_cubit.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => CartCubit(CartRepository())..load(),
        child: const _CartBody(),
      );
}

class _CartBody extends StatelessWidget {
  const _CartBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (_, locale) {
        final isAr = locale.locale.languageCode == 'ar';
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: Navigation.back,
            ),
            title: Text(isAr ? 'سلة التسوق' : 'Cart',
                style: const TextStyle(
                    fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
            actions: [
              BlocBuilder<CartCubit, CartState>(
                builder: (ctx, s) => s is CartLoaded && !s.isEmpty
                    ? TextButton(
                        onPressed: () => ctx.read<CartCubit>().clear(),
                        child: Text(isAr ? 'مسح الكل' : 'Clear',
                            style: const TextStyle(
                                fontFamily: 'Cairo', color: AppColors.error)),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          body: BlocBuilder<CartCubit, CartState>(
            builder: (ctx, state) => switch (state) {
              CartLoading() || CartInitial() => const LoadingWidget(),
              CartError(:final message) => Center(
                  child: Text(message,
                      style: const TextStyle(fontFamily: 'Cairo'))),
              CartLoaded() when state.isEmpty => EmptyStateWidget(
                  title: isAr ? 'السلة فارغة' : 'Your cart is empty',
                  subtitle: isAr
                      ? 'أضف منتجات من المتجر'
                      : 'Add products from the store',
                  actionLabel: isAr ? 'تصفح المتجر' : 'Browse Store',
                  onAction: Navigation.back,
                ),
              CartLoaded(:final items) => Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(AppSizes.md),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) => _CartTile(
                          item: items[i],
                          isAr: isAr,
                          onRemove: () =>
                              ctx.read<CartCubit>().remove(items[i].id),
                          onQtyChange: (q) =>
                              ctx.read<CartCubit>().updateQty(items[i].id, q),
                        ),
                      ),
                    ),
                    _CartSummary(state: state, isAr: isAr),
                  ],
                ),
              _ => const SizedBox.shrink(),
            },
          ),
        );
      },
    );
  }
}

// ── Cart tile ─────────────────────────────────────────────────────────────────
class _CartTile extends StatelessWidget {
  final item;
  final bool isAr;
  final VoidCallback onRemove;
  final ValueChanged<int> onQtyChange;

  const _CartTile({
    required this.item,
    required this.isAr,
    required this.onRemove,
    required this.onQtyChange,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = item.product;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            width: 0.5),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedImageWidget(imageUrl: p.thumb, width: 72, height: 72),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.localizedName(isAr),
                    style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('${p.effectivePrice.toStringAsFixed(0)} EGP',
                    style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.primary)),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.error, size: 20),
                  onPressed: onRemove),
              _QtyControl(qty: item.quantity, onChanged: onQtyChange),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyControl extends StatelessWidget {
  final int qty;
  final ValueChanged<int> onChanged;
  const _QtyControl({required this.qty, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Btn(Icons.remove, () => onChanged(qty - 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('$qty',
              style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w700,
                  fontSize: 14)),
        ),
        _Btn(Icons.add, () => onChanged(qty + 1)),
      ],
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _Btn(this.icon, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
      );
}

// ── Cart summary footer ───────────────────────────────────────────────────────
class _CartSummary extends StatelessWidget {
  final CartLoaded state;
  final bool isAr;
  const _CartSummary({required this.state, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
            top: BorderSide(
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                width: 0.5)),
      ),
      child: Column(
        children: [
          _Row(isAr ? 'المجموع الفرعي' : 'Subtotal',
              '${state.subtotal.toStringAsFixed(0)} EGP'),
          const SizedBox(height: 4),
          _Row(isAr ? 'الشحن' : 'Shipping', '50 EGP'),
          const Divider(height: 16),
          _Row(isAr ? 'الإجمالي' : 'Total',
              '${state.total.toStringAsFixed(0)} EGP',
              bold: true),
          const SizedBox(height: 14),
          CustomButton(
            label: isAr ? 'المتابعة للدفع' : 'Proceed to Checkout',
            useGradient: true,
            onTap: () => Navigation.to(CheckoutScreen(
              items: state.items.cast<CartItemModel>(),
              total: state.total,
            )),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label, value;
  final bool bold;
  const _Row(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: bold ? 15 : 13,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                  color: bold ? null : AppColors.textSecondaryLight)),
          Text(value,
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: bold ? 16 : 13,
                  fontWeight: FontWeight.w700,
                  color: bold ? AppColors.primary : null)),
        ],
      );
}
