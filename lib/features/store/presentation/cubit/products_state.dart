import 'package:equatable/equatable.dart';
import 'package:section/features/store/data/models/category_model.dart';
import 'package:section/features/store/data/models/product_model.dart';

enum ProductsStatus { initial, loading, loaded, loadingMore, error }

class ProductsState extends Equatable {
  final ProductsStatus status;
  final List<ProductModel> products;
  final List<CategoryModel> categories;
  final String? selectedCatId;
  final String sortBy;
  final double? minPrice, maxPrice, minRating;
  final Set<String> favoriteIds;
  final bool hasMore;
  final int page;
  final String? error;

  const ProductsState({this.status = ProductsStatus.initial, this.products = const [],
    this.categories = const [], this.selectedCatId, this.sortBy = 'created_at',
    this.minPrice, this.maxPrice, this.minRating, this.favoriteIds = const {},
    this.hasMore = true, this.page = 0, this.error});

  ProductsState copyWith({ProductsStatus? status, List<ProductModel>? products,
    List<CategoryModel>? categories, String? selectedCatId, bool clearCat = false,
    String? sortBy, double? minPrice, double? maxPrice, double? minRating,
    Set<String>? favoriteIds, bool? hasMore, int? page, String? error}) =>
    ProductsState(status: status ?? this.status, products: products ?? this.products,
      categories: categories ?? this.categories,
      selectedCatId: clearCat ? null : (selectedCatId ?? this.selectedCatId),
      sortBy: sortBy ?? this.sortBy, minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice, minRating: minRating ?? this.minRating,
      favoriteIds: favoriteIds ?? this.favoriteIds, hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page, error: error);

  @override List<Object?> get props => [status, products, categories, selectedCatId, sortBy, minPrice, maxPrice, minRating, favoriteIds, hasMore, page, error];
}
