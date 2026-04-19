import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:section/features/store/data/repositories/favorites_repository.dart';
import 'package:section/features/store/data/repositories/product_repository.dart';
import 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final ProductRepository _pr; final FavoritesRepository _fr;
  ProductsCubit(this._pr, this._fr) : super(const ProductsState());

  Future<void> init(String? faculty) async {
    emit(state.copyWith(status: ProductsStatus.loading));
    try {
      final cats = await _pr.getCategories();
      final favIds = await _fr.getFavoriteIds();
      final products = faculty != null ? await _pr.getFacultyPriority(faculty) : await _pr.getProducts();
      emit(state.copyWith(status: ProductsStatus.loaded, categories: cats, products: products, favoriteIds: favIds, page: 1, hasMore: products.length == 12));
    } catch (e) { emit(state.copyWith(status: ProductsStatus.error, error: e.toString())); }
  }

  Future<void> selectCategory(String? id) async {
    emit(state.copyWith(status: ProductsStatus.loading, selectedCatId: id, clearCat: id == null, page: 0));
    try {
      final p = await _pr.getProducts(catId: id);
      emit(state.copyWith(status: ProductsStatus.loaded, products: p, page: 1, hasMore: p.length == 12));
    } catch (e) { emit(state.copyWith(status: ProductsStatus.error, error: e.toString())); }
  }

  Future<void> search(String q) async {
    emit(state.copyWith(status: ProductsStatus.loading));
    try {
      final p = q.isEmpty ? await _pr.getProducts() : await _pr.searchProducts(q);
      emit(state.copyWith(status: ProductsStatus.loaded, products: p, hasMore: false));
    } catch (e) { emit(state.copyWith(status: ProductsStatus.error, error: e.toString())); }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.status == ProductsStatus.loadingMore) return;
    emit(state.copyWith(status: ProductsStatus.loadingMore));
    try {
      final more = await _pr.getProducts(page: state.page, catId: state.selectedCatId);
      emit(state.copyWith(status: ProductsStatus.loaded, products: [...state.products, ...more], page: state.page + 1, hasMore: more.length == 12));
    } catch (_) { emit(state.copyWith(status: ProductsStatus.loaded)); }
  }

  Future<void> toggleFavorite(String id) async {
    final isFav = state.favoriteIds.contains(id);
    final newFavs = Set<String>.from(state.favoriteIds);
    isFav ? newFavs.remove(id) : newFavs.add(id);
    emit(state.copyWith(favoriteIds: newFavs));
    try { isFav ? await _fr.remove(id) : await _fr.add(id); }
    catch (_) { emit(state.copyWith(favoriteIds: Set<String>.from(state.favoriteIds))); }
  }
}
