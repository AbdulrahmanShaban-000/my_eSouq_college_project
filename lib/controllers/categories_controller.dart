// lib/controllers/categories_controller.dart

import 'package:get/get.dart';
import 'package:zad/services/categories_service.dart';

class CategoriesController extends GetxController {
  // // حقن خدمة الـ CategoriesService
  // final CategoriesService _categoriesService = Get.find<CategoriesService>();

  // // متغيرات الحالة (State)
  // final RxList<Category> categoriesList = <Category>[].obs;
  // final RxBool isLoading = false.obs;
  // final RxString errorMessage = ''.obs;

  // @override
  // void onInit() {
  //   super.onInit();
  //   fetchCategories(); // جلب البيانات فور إنشاء الـ Controller
  // }

  // /// 1. جلب التصنيفات
  // Future<void> fetchCategories() async {
  //   isLoading(true);
  //   errorMessage('');
  //   try {
  //     final categories = await _categoriesService.getCategories();
  //     categoriesList.assignAll(categories);
  //   } catch (e) {
  //     errorMessage(e.toString());
  //     // يمكنك عرض SnackBar للخطأ باستخدام GetX
  //     // Get.snackbar('خطأ', e.toString());
  //   } finally {
  //     isLoading(false);
  //   }
  // }

  // /// 2. إنشاء تصنيف جديد
  // Future<void> addCategory(String name) async {
  //   try {
  //     await _categoriesService.createCategory(name: name);
  //     // بعد نجاح الإضافة، نقوم بجلب القائمة مجدداً لتحديث الواجهة
  //     await fetchCategories();
  //     Get.back(); // إغلاق شاشة الإضافة (إن وجدت)
  //     Get.snackbar('نجاح', 'تم إضافة التصنيف بنجاح');
  //   } catch (e) {
  //     Get.snackbar('خطأ', e.toString());
  //   }
  // }

  // /// 3. حذف تصنيف
  // Future<void> deleteCategory(int id) async {
  //   try {
  //     await _categoriesService.deleteCategory(id: id);
  //     categoriesList.removeWhere(
  //       (cat) => cat.id == id,
  //     ); // حذف من القائمة المحلية مباشرة
  //     Get.snackbar('نجاح', 'تم حذف التصنيف');
  //   } catch (e) {
  //     Get.snackbar('خطأ', e.toString());
  //   }
  // }
}
