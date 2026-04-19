class SubjectModel {
  final String id, nameEn, nameAr, faculty; final int academicYear, resourceCount;
  const SubjectModel({required this.id,required this.nameEn,required this.nameAr,required this.faculty,required this.academicYear,this.resourceCount=0});
  String localizedName(bool isAr) => isAr ? nameAr : nameEn;
  factory SubjectModel.fromJson(Map<String,dynamic> j) => SubjectModel(
    id:j['id'],nameEn:j['name_en'],nameAr:j['name_ar'],faculty:j['faculty'],
    academicYear:j['academic_year']??1,resourceCount:j['resource_count']??0);
}
