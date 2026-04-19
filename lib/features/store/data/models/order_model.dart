// lib/features/store/data/models/order_model.dart

class OrderItemModel {
  final String id;
  final String productId;
  final String productNameEn;
  final String productNameAr;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const OrderItemModel({
    required this.id,
    required this.productId,
    required this.productNameEn,
    required this.productNameAr,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> j) => OrderItemModel(
        id: j['id'] as String,
        productId: j['product_id'] as String,
        productNameEn: j['product_name_en'] as String? ?? '',
        productNameAr: j['product_name_ar'] as String? ?? '',
        quantity: j['quantity'] as int? ?? 1,
        unitPrice: (j['unit_price'] as num?)?.toDouble() ?? 0,
        totalPrice: (j['total_price'] as num?)?.toDouble() ?? 0,
      );

  String localizedName(bool isAr) => isAr ? productNameAr : productNameEn;
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final double subtotal;
  final double shippingFee;
  final double total;
  final Map<String, dynamic>? shippingAddress;
  final List<OrderItemModel> items;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.subtotal,
    required this.shippingFee,
    required this.total,
    this.shippingAddress,
    required this.items,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> j) => OrderModel(
        id: j['id'] as String,
        orderNumber: j['order_number'] as String? ?? '',
        status: j['status'] as String? ?? 'pending',
        paymentMethod: j['payment_method'] as String? ?? 'cash_on_delivery',
        paymentStatus: j['payment_status'] as String? ?? 'pending',
        subtotal: (j['subtotal'] as num?)?.toDouble() ?? 0,
        shippingFee: (j['shipping_fee'] as num?)?.toDouble() ?? 50,
        total: (j['total'] as num?)?.toDouble() ?? 0,
        shippingAddress: j['shipping_address'] as Map<String, dynamic>?,
        items: ((j['order_items'] as List?) ?? [])
            .map((i) => OrderItemModel.fromJson(i))
            .toList(),
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}
