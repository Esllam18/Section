class ProductModel {
  final String id, nameEn, nameAr;
  final String? descriptionEn, descriptionAr, categoryId;
  final double price;
  final double? discountPrice;
  final int stockQuantity, reviewCount, soldCount;
  final double averageRating;
  final List<String> images;
  final bool isActive, isRentable;
  final double? rentalPricePerDay;
  final DateTime createdAt;

  const ProductModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    this.descriptionEn,
    this.descriptionAr,
    this.categoryId,
    required this.price,
    this.discountPrice,
    required this.stockQuantity,
    this.reviewCount = 0,
    this.soldCount = 0,
    this.averageRating = 0,
    this.images = const [],
    this.isActive = true,
    this.isRentable = false,
    this.rentalPricePerDay,
    required this.createdAt,
  });

  bool get isOnSale => discountPrice != null && discountPrice! < price;
  double get effectivePrice => discountPrice ?? price;
  bool get inStock => stockQuantity > 0;
  String localizedName(bool isAr) => isAr ? nameAr : nameEn;
  String? localizedDesc(bool isAr) => isAr ? descriptionAr : descriptionEn;
  String? get thumb => images.isNotEmpty ? images.first : null;

  factory ProductModel.fromJson(Map<String, dynamic> j) => ProductModel(
        id: j['id'],
        nameEn: j['name_en'] ?? '',
        nameAr: j['name_ar'] ?? '',
        descriptionEn: j['description_en'],
        descriptionAr: j['description_ar'],
        categoryId: j['category_id'],
        price: (j['price'] as num).toDouble(),
        discountPrice: j['discount_price'] != null
            ? (j['discount_price'] as num).toDouble()
            : null,
        stockQuantity: j['stock_quantity'] ?? 0,
        reviewCount: j['review_count'] ?? 0,
        soldCount: j['sold_count'] ?? 0,
        averageRating: (j['average_rating'] as num?)?.toDouble() ?? 0,
        images: (j['images'] as List?)?.cast<String>() ?? [],
        isRentable: j['is_rentable'] ?? false,
        rentalPricePerDay: j['rental_price_per_day'] != null
            ? (j['rental_price_per_day'] as num).toDouble()
            : null,
        createdAt: DateTime.parse(j['created_at']),
      );
}
