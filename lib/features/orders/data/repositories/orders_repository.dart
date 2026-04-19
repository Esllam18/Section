import 'package:section/core/services/supabase_service.dart';
import 'package:section/features/orders/data/models/order_model.dart';

class OrdersRepository {
  final _db = SupabaseService.client;

  Future<List<OrderModel>> getOrders() async {
    final uid = SupabaseService.currentUserId;
    if (uid == null) return [];
    final data = await _db
        .from('orders')
        .select('*, order_items(*)')
        .eq('user_id', uid)
        .order('created_at', ascending: false);
    return (data as List<dynamic>)
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<OrderModel?> getOrderById(String id) async {
    final data = await _db
        .from('orders')
        .select('*, order_items(*)')
        .eq('id', id)
        .maybeSingle();
    if (data == null) return null;
    return OrderModel.fromJson(data);
  }
}
