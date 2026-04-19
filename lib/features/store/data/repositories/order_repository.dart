// lib/features/store/data/repositories/order_repository.dart
import 'package:section/core/services/supabase_service.dart';
import 'package:section/features/store/data/models/cart_item_model.dart';
import 'package:section/features/store/data/models/order_model.dart';

class OrderRepository {
  final _db = SupabaseService.client;

  // ── Place order ────────────────────────────────────────────────────────────
  Future<OrderModel> placeOrder({
    required List<CartItemModel> items,
    required String paymentMethod,
    required Map<String, dynamic> shippingAddress,
  }) async {
    final uid = SupabaseService.currentUserId!;
    final subtotal = items.fold(0.0, (s, i) => s + i.lineTotal);
    const shippingFee = 50.0;
    final total = subtotal + shippingFee;

    // Insert order (trigger auto-generates order_number)
    final orderRow = await _db
        .from('orders')
        .insert({
          'user_id': uid,
          'payment_method': paymentMethod,
          'payment_status': 'pending',
          'subtotal': subtotal,
          'shipping_fee': shippingFee,
          'total': total,
          'shipping_address': shippingAddress,
        })
        .select()
        .single();

    // Insert order items
    final orderItems = items
        .map((i) => {
              'order_id': orderRow['id'],
              'product_id': i.productId,
              'quantity': i.quantity,
              'unit_price': i.product.effectivePrice,
              'total_price': i.lineTotal,
              'product_name_en': i.product.nameEn,
              'product_name_ar': i.product.nameAr,
            })
        .toList();

    await _db.from('order_items').insert(orderItems);
    return OrderModel.fromJson(orderRow);
  }

  // ── Update payment status (called after Paymob result) ────────────────────
  Future<void> updatePaymentStatus(String orderId,
      {required String status, String? paymobOrderId}) async {
    await _db.from('orders').update({
      'payment_status': status,
      if (paymobOrderId != null) 'paymob_order_id': paymobOrderId,
    }).eq('id', orderId);
  }

  // ── Fetch order history ────────────────────────────────────────────────────
  Future<List<OrderModel>> getOrders() async {
    final uid = SupabaseService.currentUserId!;
    final d = await _db
        .from('orders')
        .select('*, order_items(*)')
        .eq('user_id', uid)
        .order('created_at', ascending: false);
    return (d as List<dynamic>).map((e) => OrderModel.fromJson(e as Map<String,dynamic>)).toList();
  }

  Future<OrderModel> getById(String id) async {
    final d = await _db
        .from('orders')
        .select('*, order_items(*)')
        .eq('id', id)
        .single();
    return OrderModel.fromJson(d);
  }
}
