import 'package:dio/dio.dart';

import 'dart:async';
import 'package:w2b_flutter/base_controller.dart';
import 'package:w2b_flutter/core/network_results.dart';
import 'package:w2b_flutter/models/user_model.dart';
import 'package:w2b_flutter/util/api_util.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// enum LoginPageUiEvent implements UIEvent {
//   showLoginSuccess,
//   showLoginFailure,
// }

class LoginPageController  {
  final Dio dio;

  String email = "";
  String password = "";

  LoginPageController(this.dio);

  /// Returns a Result<User> indicating success or failure of the login attempt.
  /// Handles API call, token storage, and emits UI events for success or failure.
  Future<Result<UserResponse>> handleLogin() async {
    if (email.isEmpty || password.isEmpty) {
      // emitEvent(LoginPageUiEvent.showLoginFailure);
      return Result.error("Email or password is empty");
    }
    
    try {
      // Call API to login
      UserResponse userResponse = await ApiService(dio)
        .login(
          email: email, 
          password: password,
          deviceName: "Mobile Device", // TODO: get actual device info
        );

      // User user = User(id: userResponse.email, name: userResponse.name);

      // Save email and username to userpreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', userResponse.name);
      await prefs.setString('email', userResponse.email);

      // Save token to secure storage
      const storage = FlutterSecureStorage(); // TODO: move to utils if used in 3 different places
      await storage.write(key: 'auth_token', value: userResponse.token);
      
      // emitEvent(LoginPageUiEvent.showLoginSuccess);
      return Result.success(userResponse);
    } on DioException catch (e) {
      // emitEvent(LoginPageUiEvent.showLoginFailure);
      if (e.response == null) {
        return Result.error("Network error: ${e.message}");
      } else {
        return Result.error("Login failed: ${e.response?.data['message']}", statusCode: e.response?.statusCode);
      }
      // TODO: handle different types of exceptions (network error, invalid credentials, etc.) and return more specific error messages
    }
  }
}