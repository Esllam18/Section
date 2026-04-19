import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:section/core/services/supabase_service.dart';
import 'package:section/features/store/data/models/product_model.dart';

class FavoritesRepository {
  final _db = Supabase.instance.client;

  Future<List<ProductModel>> getFavorites() async {
    final uid = SupabaseService.currentUserId;
    if (uid == null) return [];
    final d = await _db.from('favorites').select('products(*)').eq('user_id', uid);
    return (d as List<dynamic>).map((e) => ProductModel.fromJson((e as Map<String,dynamic>)['products'] as Map<String,dynamic>)).toList();
  }

  Future<Set<String>> getFavoriteIds() async {
    final uid = SupabaseService.currentUserId;
    if (uid == null) return {};
    final d = await _db.from('favorites').select('product_id').eq('user_id', uid);
    return d.map((e) => e['product_id'] as String).toSet();
  }

  Future<void> add(String productId) async {
    final uid = SupabaseService.currentUserId;
    if (uid == null) return;
    await _db.from('favorites').insert({'user_id': uid, 'product_id': productId});
  }

  Future<void> remove(String productId) async {
    final uid = SupabaseService.currentUserId;
    if (uid == null) return;
    await _db.from('favorites').delete().eq('user_id', uid).eq('product_id', productId);
  }
}
