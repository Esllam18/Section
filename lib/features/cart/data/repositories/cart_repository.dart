import 'package:section/core/services/supabase_service.dart';
import 'package:section/features/cart/data/models/cart_item_model.dart';

class CartRepository {
  final _db = SupabaseService.client;

  Future<List<CartItemModel>> getCartItems() async {
    final uid = SupabaseService.currentUserId;
    if (uid == null) return [];
    final data = await _db
        .from('cart_items')
        .select('*, products(id, name_en, name_ar, price, discount_price, images)')
        .eq('user_id', uid);
    return (data as List<dynamic>)
        .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateQuantity(String cartItemId, int qty) async {
    if (qty <= 0) {
      await _db.from('cart_items').delete().eq('id', cartItemId);
    } else {
      await _db.from('cart_items').update({'quantity': qty}).eq('id', cartItemId);
    }
  }

  Future<void> removeItem(String cartItemId) async =>
      _db.from('cart_items').delete().eq('id', cartItemId);

  Future<void> clearCart() async {
    final uid = SupabaseService.currentUserId;
    if (uid == null) return;
    await _db.from('cart_items').delete().eq('user_id', uid);
  }

  Future<void> addItem(String productId, {int quantity = 1}) async {
    final uid = SupabaseService.currentUserId;
    if (uid == null) return;
    // Check if item already exists, if so increment quantity
    final existing = await _db
        .from('cart_items')
        .select('id, quantity')
        .eq('user_id', uid)
        .eq('product_id', productId)
        .maybeSingle();
    if (existing != null) {
      final newQty = (existing['quantity'] as int) + quantity;
      await _db
          .from('cart_items')
          .update({'quantity': newQty})
          .eq('id', existing['id']);
    } else {
      await _db.from('cart_items').insert({
        'user_id': uid,
        'product_id': productId,
        'quantity': quantity,
      });
    }
  }

  Future<int> getCartCount() async {
    final uid = SupabaseService.currentUserId;
    if (uid == null) return 0;
    final data = await _db
        .from('cart_items')
        .select('quantity')
        .eq('user_id', uid);
    return (data as List<dynamic>)
        .fold<int>(0, (s, e) => s + ((e as Map)['quantity'] as int? ?? 1));
  }
}
