// lib/features/store/data/models/cart_item_model.dart
import 'package:section/features/store/data/models/product_model.dart';

class CartItemModel {
  final String id;
  final String productId;
  final int quantity;
  final ProductModel product;

  const CartItemModel({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.product,
  });

  double get lineTotal => product.effectivePrice * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> j) => CartItemModel(
        id: j['id'] as String,
        productId: j['product_id'] as String,
        quantity: j['quantity'] as int? ?? 1,
        product: ProductModel.fromJson(j['products'] as Map<String, dynamic>),
      );

  CartItemModel copyWith({int? quantity}) => CartItemModel(
        id: id,
        productId: productId,
        quantity: quantity ?? this.quantity,
        product: product,
      );
}
