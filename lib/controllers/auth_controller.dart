import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:zad/core/api/api_consumer.dart';
import 'package:zad/core/api/end_points.dart';
import 'package:zad/models/user_model.dart';
import 'package:zad/core/errors/exception.dart';
import 'package:zad/services/storage_service.dart';

class AuthController extends GetxController {
  final ApiConsumer api;

  AuthController({required this.api});

  var isLoggedIn = false.obs;
  var first_name = ''.obs;
  var phone = ''.obs;
  var last_name = ''.obs;
  // أضف هذا السطر
  var errorMessage = ''.obs;

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
    required String first_name,
    required String phone,
    required String last_name,
  }) async {
    this.first_name.value = first_name;
    this.phone.value = phone;
    this.last_name.value = last_name;

    await StorageService.saveUser(
      first_name: first_name,
      phone: phone,
      last_name: last_name,
    );
  }

  Future<void> loadUser() async {
    first_name.value = await StorageService.getFirstName();
    phone.value = await StorageService.getPhone();
    last_name.value = await StorageService.getLastName();
  }

  Future<void> login() async {
    await StorageService.setLoggedIn(true);
    isLoggedIn.value = true;
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String mobileNumber,
    required String password,
    required String passwordConfirmation,
  }) async {
    errorMessage.value = '';
    try {
      final response = await api.post(
        EndPoints.register,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'mobile_number': mobileNumber,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      if (response == null) {
        print('Register failed: empty response');
        return false;
      }

      if (response['user'] == null) {
        print('Register failed: response missing user. response=$response');
        return false;
      }

    
      if (response[ApiKeys.token] == null) {
        print('Register warning: missing token. response=$response');
      }

      final user = UserModel.fromJson(response['user']);

      await setUser(
        first_name: user.firstName,
        last_name: user.lastName,
        phone: user.mobileNumber,
      );

      final token = response[ApiKeys.token]?.toString();
      if (token != null && token.isNotEmpty) {
        await StorageService.saveToken(token);
        print('token saved: $token');
      }

      await login();

      return true;
    } catch (e) {
      if (e is ServerException) {
        errorMessage.value = e.errorModel.errorMessage;
      } else {
        errorMessage.value = 'حدث خطأ غير متوقع';
      }
      print('Register Error: ${errorMessage.value}');
      return false;
    }
  }

  Future<bool> loginApi({
    required String mobileNumber,
    required String password,
  }) async {
    errorMessage.value = '';
    try {
      final response = await api.post(
        EndPoints.login,
        data: {'mobile_number': mobileNumber, 'password': password},
      );

      if (response == null) {
        errorMessage.value = 'Empty response from server';
        print('Login failed: empty response');
        return false;
      }

      if (response['user'] == null) {
        errorMessage.value = 'User data missing from response';
        print('Login failed: response missing user. response=$response');
        return false;
      }

      final user = UserModel.fromJson(response['user']);

      final token = response[ApiKeys.token]?.toString();
      if (token == null || token.isEmpty) {
       
        print('Login warning: missing/empty token. response=$response');
      }
      if (token != null && token.isNotEmpty) {
        try {
          print('Validating token: $token');
          
          JwtDecoder.decode(token);
      
        } catch (_) {
          
        }
      }

      await setUser(
        first_name: user.firstName,
        last_name: user.lastName,
        phone: user.mobileNumber,
      );

      if (token != null && token.isNotEmpty) {
        await StorageService.saveToken(token);
      }

      // If your API returns user id as a claim, save it here.
      // Current StorageService doesn't have saveId(), so we skip it safely.
      await login();

      return true;
    } catch (e) {
      if (e is ServerException) {
        errorMessage.value = e.errorModel.errorMessage;
      } else {
        errorMessage.value = 'حدث خطأ غير متوقع';
      }

      print('Login Error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await api.post(EndPoints.logout);
      
    } catch (e) {
      print('Logout Error: $e');
    }

    final lang = await StorageService.getLanguage();

    await StorageService.logout();
    await StorageService.setLanguage(lang);

    isLoggedIn.value = false;
    first_name.value = '';
    phone.value = '';
    last_name.value = '';
  }
}
