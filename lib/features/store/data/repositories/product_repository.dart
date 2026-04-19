import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:section/features/store/data/models/category_model.dart';
import 'package:section/features/store/data/models/product_model.dart';

class ProductRepository {
  final _db = Supabase.instance.client;
  static const _pageSize = 12;

  Future<List<ProductModel>> getProducts({
    int page = 0,
    String? catId,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String sortBy = 'created_at',
  }) async {
    // Build filters first (before order/range)
    var q = _db.from('products').select().eq('is_active', true);
    if (catId != null) q = q.eq('category_id', catId);
    if (minPrice != null) q = q.gte('price', minPrice);
    if (maxPrice != null) q = q.lte('price', maxPrice);
    if (minRating != null) q = q.gte('average_rating', minRating);
    // Order and range must come last
    final data = await q
        .order(sortBy, ascending: false)
        .range(page * _pageSize, (page + 1) * _pageSize - 1);
    return (data as List<dynamic>).map((e) => ProductModel.fromJson(e as Map<String,dynamic>)).toList();
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    final data = await _db
        .from('products')
        .select()
        .eq('is_active', true)
        .or('name_en.ilike.%$query%,name_ar.ilike.%$query%')
        .limit(20);
    return (data as List<dynamic>).map((e) => ProductModel.fromJson(e as Map<String,dynamic>)).toList();
  }

  Future<ProductModel> getById(String id) async =>
      ProductModel.fromJson(
          await _db.from('products').select().eq('id', id).single());

  Future<List<CategoryModel>> getCategories() async =>
      (await _db.from('categories').select().order('sort_order'))
          .map((e) => CategoryModel.fromJson(e as Map<String,dynamic>))
          .toList();

  Future<List<ProductModel>> getFacultyPriority(String faculty) async {
    final priorities = await _db
        .from('faculty_category_priority')
        .select('category_id')
        .eq('faculty', faculty)
        .order('priority_score', ascending: false);
    final ids = priorities.map((p) => p['category_id'] as String).toList();
    if (ids.isEmpty) return getProducts();
    final priority = await _db
        .from('products')
        .select()
        .eq('is_active', true)
        .inFilter('category_id', ids)
        .limit(8);
    final others = await _db
        .from('products')
        .select()
        .eq('is_active', true)
        .not('category_id', 'in', '(${ids.join(',')})')
        .limit(12);
    return [
      ...(priority as List<dynamic>).map((e) => ProductModel.fromJson(e as Map<String,dynamic>)),
      ...(others as List<dynamic>).map((e) => ProductModel.fromJson(e as Map<String,dynamic>)),
    ];
  }
}
