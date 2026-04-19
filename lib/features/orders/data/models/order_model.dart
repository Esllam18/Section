import 'package:flutter/material.dart';
class OrderModel {
  final String id, orderNumber, status, paymentMethod, paymentStatus;
  final double subtotal, shippingFee, total;
  final DateTime createdAt;
  final List<Map<String, dynamic>> items;
  final Map<String, dynamic>? shippingAddress;

  const OrderModel({
    required this.id, required this.orderNumber, required this.status,
    required this.paymentMethod, required this.paymentStatus,
    required this.subtotal, required this.shippingFee, required this.total,
    required this.createdAt, this.items = const [], this.shippingAddress,
  });

  factory OrderModel.fromJson(Map<String, dynamic> j) => OrderModel(
    id: j['id'], orderNumber: j['order_number'] ?? '---',
    status: j['status'] ?? 'pending',
    paymentMethod: j['payment_method'] ?? 'cash_on_delivery',
    paymentStatus: j['payment_status'] ?? 'pending',
    subtotal: (j['subtotal'] as num?)?.toDouble() ?? 0,
    shippingFee: (j['shipping_fee'] as num?)?.toDouble() ?? 50,
    total: (j['total'] as num?)?.toDouble() ?? 0,
    createdAt: DateTime.parse(j['created_at']),
    items: (j['order_items'] as List?)?.cast<Map<String, dynamic>>() ?? [],
    shippingAddress: j['shipping_address'],
  );

  String statusLabel(bool isAr) {
    switch (status) {
      case 'pending':   return isAr ? 'في الانتظار' : 'Pending';
      case 'confirmed': return isAr ? 'تم التأكيد' : 'Confirmed';
      case 'preparing': return isAr ? 'جاري التجهيز' : 'Preparing';
      case 'shipped':   return isAr ? 'تم الشحن' : 'Shipped';
      case 'delivered': return isAr ? 'تم التسليم' : 'Delivered';
      case 'cancelled': return isAr ? 'ملغي' : 'Cancelled';
      default:          return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'delivered': return const Color(0xFF00C853);
      case 'cancelled': return const Color(0xFFD50000);
      case 'shipped':   return const Color(0xFF2979FF);
      case 'confirmed':
      case 'preparing': return const Color(0xFFFFAB00);
      default:          return const Color(0xFF546E7A);
    }
  }
}
