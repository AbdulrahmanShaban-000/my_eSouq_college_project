import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class AddressModel {
  String id;
  String title; // المنزل أو العمل
  String details; // العنوان الفعلي

  AddressModel({required this.id, required this.title, required this.details});
}

class AddressController extends GetxController {
  // قائمة العناوين
  var addresses = <AddressModel>[
    AddressModel(id: '1', title: 'المنزل', details: 'الرياض، شارع العليا'),
    AddressModel(id: '2', title: 'العمل', details: 'جدة، طريق الملك فهد'),
  ].obs;

  var selectedId = '1'.obs; // الافتراضي هو المنزل

  void updateAddress(String id, String newDetails) {
    int index = addresses.indexWhere((item) => item.id == id);
    if (index != -1) {
      addresses[index].details = newDetails;
      addresses.refresh(); // لتحديث الـ UI
    }
  }
}
