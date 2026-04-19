// lib/features/store/presentation/screens/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:section/core/constants/app_colors.dart';
import 'package:section/core/localization/locale_cubit.dart';
import 'package:section/core/localization/locale_state.dart';
import 'package:section/core/services/navigation/navigation.dart';
import 'package:section/core/widgets/cached_image_widget.dart';
import 'package:section/core/widgets/custom_button.dart';
import 'package:section/core/widgets/custom_snackbar.dart';
import 'package:section/features/store/data/models/product_model.dart';
import 'package:section/features/store/data/repositories/cart_repository.dart';
import 'package:section/features/store/data/repositories/favorites_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isFav     = false;
  bool _addingCart = false;
  int  _qty        = 1;
  int  _imgIdx     = 0;

  @override
  void initState() {
    super.initState();
    _checkFav();
  }

  Future<void> _checkFav() async {
    final ids = await FavoritesRepository().getFavoriteIds();
    if (mounted) setState(() => _isFav = ids.contains(widget.product.id));
  }

  Future<void> _toggleFav(bool isAr) async {
    final repo = FavoritesRepository();
    setState(() => _isFav = !_isFav);
    HapticFeedback.lightImpact();
    try {
      _isFav
          ? await repo.add(widget.product.id)
          : await repo.remove(widget.product.id);
    } catch (_) {
      setState(() => _isFav = !_isFav);
    }
  }

  Future<void> _addToCart(bool isAr) async {
    setState(() => _addingCart = true);
    try {
      await CartRepository().add(widget.product.id, quantity: _qty);
      HapticFeedback.mediumImpact();
      CustomSnackBar.show(
          message: isAr ? 'تمت الإضافة إلى السلة' : 'Added to cart',
          type: SnackBarType.success);
    } catch (_) {
      CustomSnackBar.show(
          message: isAr ? 'حدث خطأ' : 'Something went wrong',
          type: SnackBarType.error);
    }
    if (mounted) setState(() => _addingCart = false);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (_, locale) {
        final isAr = locale.locale.languageCode == 'ar';
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Image app bar
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 16, color: AppColors.textPrimaryLight)),
                  onPressed: Navigation.back,
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => _toggleFav(isAr),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle),
                        child: Icon(
                          _isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 20,
                          color: _isFav ? AppColors.error : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: p.images.isEmpty
                      ? CachedImageWidget(imageUrl: null, height: 300)
                      : PageView.builder(
                          itemCount: p.images.length,
                          onPageChanged: (i) => setState(() => _imgIdx = i),
                          itemBuilder: (_, i) => CachedImageWidget(
                              imageUrl: p.images[i], fit: BoxFit.cover),
                        ),
                ),
              ),
              // Content
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image dots
                      if (p.images.length > 1)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(p.images.length, (i) =>
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: _imgIdx == i ? 16 : 6, height: 6,
                              decoration: BoxDecoration(
                                color: _imgIdx == i
                                    ? AppColors.primary
                                    : AppColors.dividerLight,
                                borderRadius: BorderRadius.circular(3)),
                            )),
                        ),
                      if (p.images.length > 1) const SizedBox(height: 12),

                      // Name
                      Text(p.localizedName(isAr),
                          style: const TextStyle(
                              fontFamily: 'Lora',
                              fontWeight: FontWeight.w700,
                              fontSize: 20)),
                      const SizedBox(height: 8),

                      // Price row
                      Row(children: [
                        Text(
                          '${p.effectivePrice.toStringAsFixed(0)} EGP',
                          style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w700,
                              fontSize: 22,
                              color: AppColors.primary),
                        ),
                        if (p.isOnSale) ...[
                          const SizedBox(width: 10),
                          Text('${p.price.toStringAsFixed(0)} EGP',
                              style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 15,
                                  color: AppColors.textSecondaryLight,
                                  decoration: TextDecoration.lineThrough)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              '-${((1 - p.discountPrice! / p.price) * 100).round()}%',
                              style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          ),
                        ],
                      ]),
                      const SizedBox(height: 8),

                      // Rating + stock
                      Row(children: [
                        const Icon(Icons.star_rounded,
                            size: 16, color: Color(0xFFFFAB00)),
                        const SizedBox(width: 4),
                        Text(p.averageRating.toStringAsFixed(1),
                            style: const TextStyle(
                                fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 4),
                        Text('(${p.reviewCount})',
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                color: AppColors.textSecondaryLight)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (p.inStock ? AppColors.success : AppColors.error)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            p.inStock
                                ? (isAr ? 'متوفر' : 'In stock')
                                : (isAr ? 'نفد المخزون' : 'Out of stock'),
                            style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: p.inStock ? AppColors.success : AppColors.error)),
                        ),
                      ]),
                      const SizedBox(height: 16),

                      // Description
                      if (p.localizedDesc(isAr) != null) ...[
                        Text(isAr ? 'الوصف' : 'Description',
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w700,
                                fontSize: 15)),
                        const SizedBox(height: 6),
                        Text(p.localizedDesc(isAr)!,
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 14,
                                height: 1.6,
                                color: AppColors.textSecondaryLight)),
                        const SizedBox(height: 20),
                      ],

                      // Qty selector
                      Row(children: [
                        Text(isAr ? 'الكمية:' : 'Quantity:',
                            style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                        const SizedBox(width: 16),
                        _QtyRow(
                          qty: _qty,
                          max: p.stockQuantity,
                          onChanged: (q) => setState(() => _qty = q),
                        ),
                      ]),
                      const SizedBox(height: 24),

                      CustomButton(
                        label: isAr ? 'إضافة إلى السلة' : 'Add to Cart',
                        icon: Icons.add_shopping_cart_rounded,
                        useGradient: true,
                        isLoading: _addingCart,
                        onTap: p.inStock ? () => _addToCart(isAr) : null,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QtyRow extends StatelessWidget {
  final int qty, max;
  final ValueChanged<int> onChanged;
  const _QtyRow({required this.qty, required this.max, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      _Btn(Icons.remove, qty > 1 ? () => onChanged(qty - 1) : null),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text('$qty',
            style: const TextStyle(
                fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 16))),
      _Btn(Icons.add, qty < max ? () => onChanged(qty + 1) : null),
    ]);
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _Btn(this.icon, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: onTap != null
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.dividerLight,
        borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, size: 18,
          color: onTap != null ? AppColors.primary : AppColors.textHintLight)),
  );
}
