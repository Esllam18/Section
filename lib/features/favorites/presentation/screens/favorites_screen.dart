// lib/features/favorites/presentation/screens/favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:section/core/constants/app_colors.dart';
import 'package:section/core/services/navigation/navigation.dart';
import 'package:section/core/services/supabase_service.dart';
import 'package:section/core/widgets/cached_image_widget.dart';
import 'package:section/core/widgets/empty_state_widget.dart';
import 'package:section/core/widgets/shimmer_widget.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Map<String, dynamic>>? _items;
  bool _loading = true;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final uid = SupabaseService.currentUserId;
    if (uid == null) { setState(() => _loading = false); return; }
    setState(() => _loading = true);
    try {
      final data = await SupabaseService.client
          .from('favorites')
          .select('*, products(id, name_en, name_ar, price, discount_price, images, average_rating)')
          .eq('user_id', uid)
          .order('created_at', ascending: false);
      if (mounted) setState(() {
        _items = List<Map<String, dynamic>>.from(data);
        _loading = false;
      });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _removeFavorite(String favId) async {
    await SupabaseService.client.from('favorites').delete().eq('id', favId);
    setState(() => _items?.removeWhere((i) => i['id'] == favId));
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: Navigation.back),
        title: Text(isAr ? 'المفضلة' : 'Favorites',
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
      ),
      body: _loading
        ? GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.75),
            itemCount: 6,
            itemBuilder: (_, __) => ShimmerWidget(height: 200, borderRadius: 12),
          )
        : _items == null || _items!.isEmpty
          ? EmptyStateWidget(
              title: isAr ? 'لا توجد مفضلة' : 'No Favorites Yet',
              subtitle: isAr ? 'أضف منتجات إلى المفضلة من المتجر' : 'Add products to favorites from the store',
            )
          : RefreshIndicator(
              onRefresh: _load,
              color: AppColors.secondary,
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.72),
                itemCount: _items!.length,
                itemBuilder: (_, i) {
                  final fav = _items![i];
                  final p = fav['products'] as Map<String, dynamic>?;
                  final images = (p?['images'] as List?)?.cast<String>() ?? [];
                  final price = (p?['price'] as num?)?.toDouble() ?? 0;
                  final discPrice = p?['discount_price'] != null ? (p!['discount_price'] as num).toDouble() : null;
                  final name = isAr ? (p?['name_ar'] ?? '') : (p?['name_en'] ?? '');
                  return _FavCard(
                    name: name,
                    image: images.isNotEmpty ? images.first : null,
                    price: price,
                    discountPrice: discPrice,
                    rating: (p?['average_rating'] as num?)?.toDouble() ?? 0,
                    onRemove: () => _removeFavorite(fav['id']),
                  );
                },
              ),
            ),
    );
  }
}

class _FavCard extends StatelessWidget {
  final String name; final String? image;
  final double price; final double? discountPrice; final double rating;
  final VoidCallback onRemove;
  const _FavCard({required this.name, this.image, required this.price,
    this.discountPrice, required this.rating, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectivePrice = discountPrice ?? price;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Stack(children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: CachedImageWidget(imageUrl: image, width: double.infinity, height: 120),
          ),
          Positioned(top: 6, right: 6,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                child: const Icon(Icons.favorite_rounded, color: AppColors.error, size: 16),
              ),
            )),
        ]),
        Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 13),
            maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.star_rounded, color: AppColors.warning, size: 13),
            const SizedBox(width: 2),
            Text(rating.toStringAsFixed(1),
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textSecondaryLight)),
            const Spacer(),
            Text('${effectivePrice.toStringAsFixed(0)} ج',
              style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700,
                  fontSize: 13, color: AppColors.primary)),
          ]),
        ])),
      ]),
    );
  }
}
