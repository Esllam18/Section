// lib/features/cart/data/models/cart_item_model.dart
class CartItemModel {
  final String id, productId, productNameEn, productNameAr;
  final String? productImage;
  final double price; final double? discountPrice;
  final int quantity;

  const CartItemModel({
    required this.id, required this.productId,
    required this.productNameEn, required this.productNameAr,
    this.productImage, required this.price, this.discountPrice,
    required this.quantity,
  });

  double get effectivePrice => discountPrice ?? price;
  double get subtotal => effectivePrice * quantity;
  String localizedName(bool isAr) => isAr ? productNameAr : productNameEn;

  CartItemModel copyWith({int? quantity}) => CartItemModel(
    id: id, productId: productId,
    productNameEn: productNameEn, productNameAr: productNameAr,
    productImage: productImage, price: price, discountPrice: discountPrice,
    quantity: quantity ?? this.quantity,
  );

  factory CartItemModel.fromJson(Map<String, dynamic> j) {
    final p = j['products'] as Map<String, dynamic>?;
    return CartItemModel(
      id: j['id'], productId: j['product_id'],
      productNameEn: p?['name_en'] ?? '',
      productNameAr: p?['name_ar'] ?? '',
      productImage: (p?['images'] as List?)?.isNotEmpty == true ? p!['images'][0] : null,
      price: (p?['price'] as num?)?.toDouble() ?? 0,
      discountPrice: p?['discount_price'] != null ? (p!['discount_price'] as num).toDouble() : null,
      quantity: j['quantity'] ?? 1,
    );
  }
}
