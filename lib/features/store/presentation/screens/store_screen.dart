// lib/features/store/presentation/screens/store_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:section/core/constants/app_colors.dart';
import 'package:section/core/services/navigation/navigation.dart';
import 'package:section/core/services/supabase_service.dart';
import 'package:section/core/widgets/cached_image_widget.dart';
import 'package:section/core/widgets/custom_snackbar.dart';
import 'package:section/core/widgets/error_state_widget.dart';
import 'package:section/core/widgets/shimmer_widget.dart';
import 'package:section/features/cart/data/repositories/cart_repository.dart';
import 'package:section/features/cart/presentation/screens/cart_screen.dart';
import 'package:section/features/store/data/repositories/favorites_repository.dart';
import 'package:section/features/store/data/repositories/product_repository.dart';
import 'package:section/features/store/presentation/cubit/products_cubit.dart';
import 'package:section/features/store/presentation/cubit/products_state.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => ProductsCubit(ProductRepository(), FavoritesRepository()),
    child: const _StoreView(),
  );
}

class _StoreView extends StatefulWidget {
  const _StoreView();
  @override State<_StoreView> createState() => _StoreViewState();
}

class _StoreViewState extends State<_StoreView> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _cartRepo = CartRepository();
  int _cartCount = 0;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
        context.read<ProductsCubit>().loadMore();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final uid = SupabaseService.currentUserId;
      String? faculty;
      if (uid != null) {
        final p = await SupabaseService.client.from('profiles').select('faculty').eq('id', uid).maybeSingle();
        faculty = p?['faculty'] as String?;
      }
      if (mounted) {
        context.read<ProductsCubit>().init(faculty);
        _loadCartCount();
      }
    });
  }

  Future<void> _loadCartCount() async {
    final count = await _cartRepo.getCartCount();
    if (mounted) setState(() => _cartCount = count);
  }

  Future<void> _addToCart(String productId, bool isAr) async {
    try {
      await _cartRepo.addItem(productId);
      await _loadCartCount();
      HapticFeedback.lightImpact();
      CustomSnackBar.show(
        message: isAr ? 'تمت الإضافة إلى السلة ✓' : 'Added to cart ✓',
        type: SnackBarType.success,
      );
    } catch (e) {
      CustomSnackBar.show(
        message: isAr ? 'حدث خطأ' : 'Something went wrong',
        type: SnackBarType.error,
      );
    }
  }

  @override
  void dispose() { _searchCtrl.dispose(); _scrollCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (ctx, state) => Scaffold(
        body: RefreshIndicator(
          color: AppColors.secondary,
          onRefresh: () => ctx.read<ProductsCubit>().init(null),
          child: CustomScrollView(
            controller: _scrollCtrl,
            slivers: [
              _appBar(ctx, state, isAr),
              if (state.status == ProductsStatus.loading)
                _shimmerGrid()
              else if (state.status == ProductsStatus.error)
                SliverFillRemaining(child: ErrorStateWidget(
                  message: state.error ?? 'Error',
                  onRetry: () => ctx.read<ProductsCubit>().init(null)))
              else ...[
                _productGrid(ctx, state, isAr),
                if (state.status == ProductsStatus.loadingMore)
                  const SliverToBoxAdapter(child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator(color: AppColors.secondary)))),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBar(BuildContext ctx, ProductsState state, bool isAr) {
    return SliverAppBar(
      floating: true, snap: true, pinned: false, expandedHeight: 118,
      title: Text(isAr ? 'المتجر' : 'Store',
        style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 18)),
      actions: [
        Stack(children: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () async {
              await Navigation.to(const CartScreen());
              _loadCartCount();
            },
          ),
          if (_cartCount > 0) Positioned(top: 6, right: 6,
            child: Container(
              width: 16, height: 16,
              decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
              child: Text('$_cartCount',
                style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center),
            )),
        ]),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.fromLTRB(12, 56, 12, 6),
          child: Column(children: [
            Row(children: [
              Expanded(child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => ctx.read<ProductsCubit>().search(v),
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
                decoration: InputDecoration(
                  hintText: isAr ? 'ابحث عن منتجات...' : 'Search products...',
                  prefixIcon: const Icon(Icons.search, size: 20), isDense: true),
              )),
            ]),
            const SizedBox(height: 6),
            SizedBox(height: 34, child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 2),
              children: [
                _catChip(ctx, null, isAr ? 'الكل' : 'All', state.selectedCatId == null),
                ...state.categories.map((c) => _catChip(ctx, c.id, c.localizedName(isAr), state.selectedCatId == c.id)),
              ],
            )),
          ]),
        ),
      ),
    );
  }

  Widget _catChip(BuildContext ctx, String? id, String label, bool selected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: TextStyle(
          fontFamily: 'Cairo', fontSize: 12,
          color: selected ? Colors.white : AppColors.textSecondaryLight)),
        selected: selected,
        onSelected: (_) => ctx.read<ProductsCubit>().selectCategory(id),
        selectedColor: AppColors.secondary,
        backgroundColor: AppColors.backgroundLight,
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _shimmerGrid() => SliverPadding(
    padding: const EdgeInsets.all(12),
    sliver: SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (_, __) => const ShimmerWidget(height: 220, borderRadius: 16), childCount: 6),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 12, mainAxisSpacing: 12),
    ),
  );

  Widget _productGrid(BuildContext ctx, ProductsState state, bool isAr) {
    if (state.products.isEmpty) {
      return SliverFillRemaining(child: Center(child: Text(
        isAr ? 'لا توجد منتجات' : 'No products',
        style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondaryLight))));
    }
    return SliverPadding(
      padding: const EdgeInsets.all(12),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate((_, i) {
          final p = state.products[i];
          final isFav = state.favoriteIds.contains(p.id);
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return GestureDetector(
            onTap: () {},
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Stack(children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: AspectRatio(
                      aspectRatio: 1 / 1.1,
                      child: CachedImageWidget(imageUrl: p.thumb, fit: BoxFit.cover))),
                  Positioned(top: 8, right: 8,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ctx.read<ProductsCubit>().toggleFavorite(p.id);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Icon(isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 17, color: isFav ? AppColors.error : AppColors.textSecondaryLight)))),
                  if (p.isOnSale) Positioned(top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        '-${((1 - p.discountPrice! / p.price) * 100).round()}%',
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 10,
                          fontWeight: FontWeight.w700, color: Colors.white)))),
                  if (!p.inStock) Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
                      child: Center(child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                        child: Text(isAr ? 'نفد المخزون' : 'Out of Stock',
                          style: const TextStyle(fontFamily: 'Cairo', fontSize: 10,
                            fontWeight: FontWeight.w700, color: Colors.white)))))),
                ]),
                Expanded(child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(p.localizedName(isAr),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 12)),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        const Icon(Icons.star_rounded, size: 12, color: Color(0xFFFFAB00)),
                        const SizedBox(width: 2),
                        Text(p.averageRating.toStringAsFixed(1),
                          style: const TextStyle(fontFamily: 'Cairo', fontSize: 11,
                            color: AppColors.textSecondaryLight)),
                        if (p.reviewCount > 0) ...[
                          const SizedBox(width: 4),
                          Text('(${p.reviewCount})',
                            style: const TextStyle(fontFamily: 'Cairo', fontSize: 10,
                              color: AppColors.textSecondaryLight)),
                        ],
                      ]),
                      const SizedBox(height: 5),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          if (p.isOnSale)
                            Text('${p.price.toStringAsFixed(0)} ج',
                              style: const TextStyle(fontFamily: 'Cairo', fontSize: 10,
                                color: AppColors.textSecondaryLight,
                                decoration: TextDecoration.lineThrough)),
                          Text('${p.effectivePrice.toStringAsFixed(0)} ج',
                            style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700,
                              fontSize: 13, color: AppColors.primary)),
                        ]),
                        GestureDetector(
                          onTap: p.inStock ? () => _addToCart(p.id, isAr) : null,
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: p.inStock ? AppColors.secondary : AppColors.dividerLight,
                              borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.add_shopping_cart_rounded,
                              size: 15, color: Colors.white))),
                      ]),
                    ]),
                  ]),
                )),
              ]),
            ),
          );
        }, childCount: state.products.length),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 0.63, crossAxisSpacing: 12, mainAxisSpacing: 12),
      ),
    );
  }
}
