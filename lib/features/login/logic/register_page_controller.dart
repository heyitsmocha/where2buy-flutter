import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:w2b_flutter/core/network_results.dart';
import 'package:w2b_flutter/models/user_model.dart';
import 'package:w2b_flutter/util/api_util.dart';

class RegisterPageController {
  final Dio dio;
  String email = '';
  String name = '';
  String password = '';
  String confirmPassword = '';

  RegisterPageController(this.dio);

  Future<Result<void>> handleRegister() async {
    // Also check here just in case, to prevent unnecessary API calls if the form validation is somehow bypassed
    if (email.isEmpty || name.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      return Result.error("Please fill in all fields");
    }
    if (password != confirmPassword) {
      return Result.error("Passwords do not match");
    }

    try {
      RegisterResponse response = await ApiService(dio).register(
        RegisterRequest(
          name: name,
          email: email, 
          password: password, 
          passwordConfirmation: confirmPassword,
          deviceName: "Mobile Device", // TODO: get actual device info
        )
      );

      // Backend automatically logs the user in and provides the token, so we can save it directly without needing to call login again
      const storage = FlutterSecureStorage();
      await storage.write(key: 'auth_token', value: response.token);

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('username', name);
      prefs.setString('email', email);

      return Result.success(null);
    } on DioException catch (e) {
      if (e.response == null) {
        return Result.error("Network error: ${e.message}");
      } else {
        return Result.error("Registration failed: ${e.response?.data['message']}", statusCode: e.response?.statusCode);
      }
    }
  }
}