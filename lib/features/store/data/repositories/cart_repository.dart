// lib/features/store/data/repositories/cart_repository.dart
import 'package:section/core/services/supabase_service.dart';
import 'package:section/features/store/data/models/cart_item_model.dart';

class CartRepository {
  final _db = SupabaseService.client;
  static const _table = 'cart_items';

  Future<List<CartItemModel>> getItems() async {
    final uid = SupabaseService.currentUserId!;
    final d = await _db
        .from(_table)
        .select('*, products(*)')
        .eq('user_id', uid)
        .order('created_at', ascending: false);
    return (d as List<dynamic>).map((e) => CartItemModel.fromJson(e as Map<String,dynamic>)).toList();
  }

  Future<void> add(String productId, {int quantity = 1}) async {
    final uid = SupabaseService.currentUserId!;
    // Upsert: if already in cart, increase quantity
    final existing = await _db
        .from(_table)
        .select('id, quantity')
        .eq('user_id', uid)
        .eq('product_id', productId)
        .maybeSingle();

    if (existing != null) {
      await _db.from(_table).update({
        'quantity': (existing['quantity'] as int) + quantity,
      }).eq('id', existing['id']);
    } else {
      await _db.from(_table).insert({
        'user_id': uid,
        'product_id': productId,
        'quantity': quantity,
      });
    }
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    if (quantity < 1) return remove(itemId);
    await _db.from(_table).update({'quantity': quantity}).eq('id', itemId);
  }

  Future<void> remove(String itemId) async {
    await _db.from(_table).delete().eq('id', itemId);
  }

  Future<void> clearCart() async {
    final uid = SupabaseService.currentUserId!;
    await _db.from(_table).delete().eq('user_id', uid);
  }
}
