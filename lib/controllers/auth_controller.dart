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
  var errorMessage = ''.obs;
  var verificationId = ''.obs;

  // بيانات التسجيل المعلقة (تُرسَل مع رمز التحقق لأن الـ Backend يتطلبها دائماً)
  String _pendingFirstName = '';
  String _pendingLastName = '';
  String _pendingMobileNumber = '';
  String _pendingPassword = '';

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

  
  bool get hasValidToken {
    if (!isLoggedIn.value) return false;
    // نستخدم getToken() مع Future
    // لكن لا يمكن استخدام await في getter
    // لذا نستخدم طريقة مختلفة
    return false; // سيتم تعديلها
  }

  // ✅ دالة للحصول على Token بشكل صحيح (غير متزامنة)
  Future<String?> getToken() async {
    if (!isLoggedIn.value) return null;
    return await StorageService.getToken();
  }

  // ✅ دالة للتحقق من وجود Token صالح (غير متزامنة)
  Future<bool> checkValidToken() async {
    if (!isLoggedIn.value) return false;
    final token = await StorageService.getToken();
    return token != null && token.isNotEmpty;
  }

  // ✅ دالة لتحديث حالة المستخدم
  Future<void> refreshAuthStatus() async {
    isLoggedIn.value = await StorageService.isLoggedIn();
    if (isLoggedIn.value) {
      await loadUser();
    }
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

      // استخراج verification_id إذا كان التسجيل يتطلب تأكيد (رمز تحقق)
      verificationId.value = response['verification_id']?.toString() ?? '';

      // إذا كان التسجيل يتطلب رمز تحقق، لا نسجل الدخول بعد
      if (verificationId.value.isNotEmpty) {
        // حفظ بيانات التسجيل كاملة لإرسالها مع رمز التحقق (الـ Backend يتطلبها دائماً)
        _pendingFirstName = firstName;
        _pendingLastName = lastName;
        _pendingMobileNumber = mobileNumber;
        _pendingPassword = password;

        if (response['user'] != null) {
          final pendingUser = UserModel.fromJson(response['user']);
          await setUser(
            first_name: pendingUser.firstName,
            last_name: pendingUser.lastName,
            phone: pendingUser.mobileNumber,
          );
        }
        print(
          'Register: verification required. verification_id=${verificationId.value}',
        );
        return true;
      }

      if (response['user'] == null) {
        print('Register failed: response missing user. response=$response');
        return false;
      }

      final user = UserModel.fromJson(response['user']);

      await setUser(
        first_name: user.firstName,
        last_name: user.lastName,
        phone: user.mobileNumber,
      );

      final token = response['token']?.toString();
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

  /// ✅ التحقق من حساب المستخدم عبر الرمز المرسل.
  ///
  /// الرابط المرسل للمستخدم يكون بالشكل:
  /// http://localhost:8000/api/register?verification_id=...&code=...
  Future<bool> verifyRegistration({
    required String verificationId,
    required String code,
  }) async {
    errorMessage.value = '';

    if (verificationId.trim().isEmpty) {
      errorMessage.value = 'verification_id_required'.tr;
      print('Verify failed: verificationId is empty');
      return false;
    }

    try {
      final response = await api.post(
        EndPoints.register,
        data: {
          'verification_id': verificationId.trim(),
          'code': code.trim(),
          'first_name': _pendingFirstName,
          'last_name': _pendingLastName,
          'mobile_number': _pendingMobileNumber,
          'password': _pendingPassword,
          'password_confirmation': _pendingPassword,
        },
      );

      if (response == null) {
        errorMessage.value = 'Empty response from server';
        print('Verify failed: empty response');
        return false;
      }

      if (response['user'] != null) {
        final user = UserModel.fromJson(response['user']);
        await setUser(
          first_name: user.firstName,
          last_name: user.lastName,
          phone: user.mobileNumber,
        );
      }

      final token = response['token']?.toString();
      if (token != null && token.isNotEmpty) {
        await StorageService.saveToken(token);
        print('token saved after verification: $token');
      }

      await login();
      this.verificationId.value = '';
      return true;
    } catch (e) {
      if (e is ServerException) {
        errorMessage.value = e.errorModel.errorMessage;
      } else {
        errorMessage.value = 'حدث خطأ غير متوقع';
      }
      print('Verify Error: ${errorMessage.value}');
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

      final token = response['token']?.toString();
      if (token != null && token.isNotEmpty) {
        try {
          print('Validating token: $token');
          JwtDecoder.decode(token);
        } catch (_) {
          print('Token validation warning');
        }
        await StorageService.saveToken(token);
        print('Token saved successfully');
      }

      await setUser(
        first_name: user.firstName,
        last_name: user.lastName,
        phone: user.mobileNumber,
      );

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

    // حذف جميع بيانات المستخدم بما في ذلك Token
    await StorageService.logout();
    await StorageService.deleteToken();
    await StorageService.setLanguage(lang);

    isLoggedIn.value = false;
    first_name.value = '';
    phone.value = '';
    last_name.value = '';
  }
}
