// // lib/services/categories_service.dart

import 'package:zad/core/api/api_consumer.dart';
import 'package:zad/core/api/end_points.dart';
import 'package:zad/models/categories.dart';

class CategoriesService {
  final ApiConsumer api;

  CategoriesService({required this.api});

  // /// جلب جميع التصنيفات
  // Future<List<Categories>> getCategories() async {
  //   final response = await api.get(EndPoints.categories);

  //   // تعديل حسب شكل استجابة السيرفر الخاص بك
  //   final List<dynamic> categoriesJson = response['data'] ?? response;
  //   return categoriesJson.map((json) => Categories.fromJson(json)).toList();
  // }

  // /// إنشاء تصنيف جديد
  // Future<void> createCategories({required String name}) async {
  //   await api.post(EndPoints.categories, data: {'name': name});
  // }

  // /// تحديث تصنيف
  // Future<void> updateCategories({required int id, required String name}) async {
  //   await api.put('${EndPoints.categories}/$id', data: {'name': name});
  // }

  // /// حذف تصنيف
  // Future<void> deleteCategories({required int id}) async {
  //   await api.delete('${EndPoints.categories}/$id');
  // }
}
