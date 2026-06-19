import 'package:get/get.dart';
 

class AddressModel {
  String id;
  String title; 
  String details; 

  AddressModel({required this.id, required this.title, required this.details});
}

class AddressController extends GetxController {
  // قائمة العناوين
  var addresses = <AddressModel>[
    AddressModel(id: '1', title: 'المنزل', details: 'اختر عنوان المنزل هنا'),
    AddressModel(id: '2', title: 'العمل', details: 'اختر عنوان العمل هنا'),
  ].obs;

  var selectedId = '1'.obs; 
  void updateAddress(String id, String newDetails) {
    int index = addresses.indexWhere((item) => item.id == id);
    if (index != -1) {
      addresses[index].details = newDetails;
      addresses.refresh();
    }
  }
}
