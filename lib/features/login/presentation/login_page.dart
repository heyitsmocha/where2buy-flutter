import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:w2b_flutter/base_state.dart';
import 'package:w2b_flutter/components/base_layout.dart';
import 'package:w2b_flutter/core/network_results.dart';
import 'package:w2b_flutter/features/login/logic/login_page_controller.dart';
import 'package:w2b_flutter/models/user_model.dart';

class LoginPage extends StatefulWidget {
  final Dio dio;

  const LoginPage(
    this.dio, {
    super.key,
    required this.onLoginFailure,
    required this.onLoginSuccess,
  });

  final Function() onLoginSuccess;
  final Function(String) onLoginFailure;

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

// class _LoginPageState extends BaseState<LoginPage, LoginPageController, LoginPageUiEvent> {
class _LoginPageState extends State<LoginPage> {
  late final LoginPageController controller;


  @override
  void initState() {
    super.initState();
    controller = LoginPageController(widget.dio);
  }

  // @override
  // LoginPageController initController() => LoginPageController(widget.dio);
  
  // @override
  // void handleUIEvent(event) {
  //   switch (event) {
  //     case LoginPageUiEvent.showLoginSuccess:
  //       widget.onLoginSuccess();
  //       break;
  //     case LoginPageUiEvent.showLoginFailure:
  //       // widget.onLoginFailure();
  //       break;
  //   }
  // }

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Text('Login', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextFormField(
            onChanged: (value) => controller.email = value,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextFormField(
            onChanged: (value) => controller.password = value,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: 
            _isLoading 
            ? null
            : () async {
              setState(() => _isLoading = true);
              Result<UserResponse> result = await controller.handleLogin();
              switch (result) {
                case Success():
                  widget.onLoginSuccess();
                  break;
                case Failure():
                  widget.onLoginFailure(result.errorMessage);
                  break;
              }
              setState(() => _isLoading = false);
            },
            child: 
              _isLoading
              ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 3),
               )
              : const Text('Login'),
          ),
        ],
      ),
    );
  }
}