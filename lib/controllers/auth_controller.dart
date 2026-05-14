import 'package:get/get.dart';
import 'package:my_esouq/services/storage_service.dart';

class AuthController extends GetxController {
  var isLoggedIn = false.obs;

  var name = "".obs;
  var phone = "".obs;
  var email = "".obs;
  var imagePath = "".obs;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    await _loadLoginStatus();
    await loadUser();
  }

  Future<void> _loadLoginStatus() async {
    isLoggedIn.value = await StorageService.isLoggedIn();
  }


  Future<void> setUser({
    required String name,
    required String phone,
    required String email,
    required String image,
  }) async {
    this.name.value = name;
    this.phone.value = phone;
    this.email.value = email;
    imagePath.value = image;

  await StorageService.saveUser(
      name: name,
      phone: phone,
      email: email,
      image: image,
    );
  }

  /// ✅ تحميل المستخدم
  Future<void> loadUser() async {
    name.value = await StorageService.getName();
    phone.value = await StorageService.getPhone();
    email.value = await StorageService.getEmail();
    imagePath.value = await StorageService.getImage();
  }

  Future<void> login() async {
    await StorageService.setLoggedIn(true);
    isLoggedIn.value = true;
  }

  Future<void> logout() async {
    await StorageService.logout();

    isLoggedIn.value = false;
    name.value = '';
    phone.value = '';
    email.value = '';
    imagePath.value = '';
  }
}
