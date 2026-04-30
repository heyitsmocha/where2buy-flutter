import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:w2b_flutter/components/responsive_bottom_sheet_scaffold.dart';
import 'package:w2b_flutter/core/network_results.dart';
import 'package:w2b_flutter/features/login/presentation/auth_success_page.dart';
import 'package:w2b_flutter/features/login/presentation/login_page.dart';
import 'package:w2b_flutter/features/login/presentation/register_page.dart';

class AuthUtil {
  static Future<bool> isLoggedIn() async {
    const FlutterSecureStorage storage = FlutterSecureStorage();
    final String? token = await storage.read(key: 'auth_token');
    return token != null;
  }

  /// Shows the login/registration form as a bottom sheet. </br> </br>
  /// If the login/registration is successful, the bottom sheet will automatically dismiss after 3 seconds and return a [Result.success]. </br>
  /// Errors will be shown as snackbars within the bottom sheet. </br> </br>
  /// [onAuthSuccess] and [onAuthFailure] can perform additional actions before the bottom sheet is dismissed, they provide the success or error message as a parameter. </br>
  /// Must be awaited to perform actions after the bottom sheet is dismissed
  static Future<Result> showAuthForm(
    BuildContext context, 
    Dio dio, {
    Function(String)? onAuthSuccess, 
    Function(String)? onAuthFailure}
  ) async {
    // Can be either "Login" or "Register", used to determine which action was successful in the AuthSuccessPage
    final ValueNotifier<String> authMethodNotifier = ValueNotifier<String>("");
    // Await the bottom sheet for Result.success
    await showModalBottomSheet<Result>(
      isScrollControlled: true,
      context: context, 
      builder: (context) {
        PageController pageController = PageController(initialPage: 0);

        return ResponsiveBottomSheetScaffold(
          showAppBar: false,
          child: PageView(
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(), // Disable swipe to change pages
            children: [
              LoginPage(
                dio,
                onGoToRegister: () {
                  pageController.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                },
                onLoginFailure: (message) {
                  if (onAuthFailure != null) {
                    onAuthFailure(message);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text(message)
                    ),
                  );
                }, 
                onLoginSuccess: () {
                  authMethodNotifier.value = "Login";
                  return pageController.animateToPage(2, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                },
              ),
              RegisterPage(
                dio: dio,
                onGoToLogin: () {
                  pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                },
                // Pop the modal and pass success Result with string to indicate registration success
                onRegisterSuccess: () {
                  authMethodNotifier.value = "Register";
                  pageController.animateToPage(2, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                },
              ),
              AuthSuccessPage(
                dataNotifier: authMethodNotifier,
                onAuthSuccess: onAuthSuccess,
              ),
            ],
          ),
        );
      }
    );

    // authMethodNotifier only gets a value if login or registration is successful, so we can determine the result based on that
    bool authSuccess = authMethodNotifier.value.isNotEmpty;
    print('AuthUtil: authMethodNotifier.value = ${authMethodNotifier.value}');
    return authSuccess ? Result.success(authMethodNotifier.value) : Result.error("Login cancelled");
  }
}