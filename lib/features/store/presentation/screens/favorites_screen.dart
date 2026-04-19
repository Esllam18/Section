// lib/features/store/presentation/screens/favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:section/core/constants/app_colors.dart';
import 'package:section/core/localization/locale_cubit.dart';
import 'package:section/core/localization/locale_state.dart';
import 'package:section/core/services/navigation/navigation.dart';
import 'package:section/core/widgets/cached_image_widget.dart';
import 'package:section/core/widgets/custom_snackbar.dart';
import 'package:section/core/widgets/empty_state_widget.dart';
import 'package:section/core/widgets/loading_widget.dart';
import 'package:section/features/store/data/models/product_model.dart';
import 'package:section/features/store/data/repositories/cart_repository.dart';
import 'package:section/features/store/data/repositories/favorites_repository.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<ProductModel> _items = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _items = await FavoritesRepository().getFavorites();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _remove(String productId, bool isAr) async {
    await FavoritesRepository().remove(productId);
    setState(() => _items.removeWhere((p) => p.id == productId));
    CustomSnackBar.show(
        message: isAr ? 'تم الحذف من المفضلة' : 'Removed from favorites',
        type: SnackBarType.info);
  }

  Future<void> _addToCart(String productId, bool isAr) async {
    try {
      await CartRepository().add(productId);
      CustomSnackBar.show(
          message: isAr ? 'تمت الإضافة إلى السلة' : 'Added to cart',
          type: SnackBarType.success);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (_, locale) {
        final isAr = locale.locale.languageCode == 'ar';
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: Navigation.back),
            title: Text(isAr ? 'المفضلة' : 'Favorites',
                style: const TextStyle(
                    fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
          ),
          body: _loading
              ? const LoadingWidget()
              : _items.isEmpty
                  ? EmptyStateWidget(
                      title: isAr ? 'لا توجد مفضلات' : 'No favorites yet',
                      subtitle: isAr
                          ? 'اضغط ♡ على أي منتج لإضافته'
                          : 'Tap ♡ on any product to save it',
                    )
                  : RefreshIndicator(
                      color: AppColors.secondary,
                      onRefresh: _load,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(14),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _items.length,
                        itemBuilder: (_, i) => _FavCard(
                          product: _items[i],
                          isAr: isAr,
                          isDark: isDark,
                          onRemove: () => _remove(_items[i].id, isAr),
                          onAddToCart: () => _addToCart(_items[i].id, isAr),
                        ),
                      ),
                    ),
        );
      },
    );
  }
}

class _FavCard extends StatelessWidget {
  final ProductModel product;
  final bool isAr, isDark;
  final VoidCallback onRemove, onAddToCart;

  const _FavCard({
    required this.product, required this.isAr, required this.isDark,
    required this.onRemove, required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final p = product;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Stack(children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AspectRatio(
                aspectRatio: 1,
                child: CachedImageWidget(imageUrl: p.thumb, fit: BoxFit.cover)),
          ),
          Positioned(top: 8, right: 8,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.favorite_rounded, size: 17, color: AppColors.error)),
            )),
        ]),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.localizedName(isAr), maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 12)),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${p.effectivePrice.toStringAsFixed(0)} EGP',
                  style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700,
                      fontSize: 13, color: AppColors.primary)),
              GestureDetector(
                onTap: p.inStock ? onAddToCart : null,
                child: Container(padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: p.inStock ? AppColors.secondary : AppColors.dividerLight,
                    borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.add_shopping_cart_rounded, size: 15, color: Colors.white)),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }
}
