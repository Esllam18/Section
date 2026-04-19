class CategoryModel {
  final String id, nameEn, nameAr;
  final int sortOrder;
  const CategoryModel({required this.id, required this.nameEn, required this.nameAr, this.sortOrder = 0});
  String localizedName(bool isAr) => isAr ? nameAr : nameEn;
  factory CategoryModel.fromJson(Map<String, dynamic> j) =>
    CategoryModel(id: j['id'], nameEn: j['name_en'], nameAr: j['name_ar'], sortOrder: j['sort_order'] ?? 0);
}
