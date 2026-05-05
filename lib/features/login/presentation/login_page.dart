import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w2b_flutter/auth_state.dart';
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
    this.onGoToRegister,
  });

  final Function() onLoginSuccess;
  final Function(String) onLoginFailure;
  final Function()? onGoToRegister;

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

// class _LoginPageState extends BaseState<LoginPage, LoginPageController, LoginPageUiEvent> {
class _LoginPageState extends State<LoginPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final LoginPageController controller;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
    super.build(context); // For AutomaticKeepAliveClientMixin to work
    AuthState authState = context.read<AuthState>();

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Login'), 
              centerTitle: true, 
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close), 
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],),
            const SizedBox(height: 16),
            TextFormField(
              textInputAction: TextInputAction.next,
              onChanged: (value) => controller.email = value,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) => (value != null && value.contains('@')) ? null : 'Please enter a valid email',
            ),
            TextFormField(
              onChanged: (value) => controller.password = value,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (value) => (value != null && value.length >= 6) ? null : 'Password must be at least 6 characters',
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: 
              _isLoading 
              ? null
              : () async {
                if (!_formKey.currentState!.validate()) {
                  return;
                }
                setState(() => _isLoading = true);
                Result<UserResponse> result = await controller.handleLogin();
                switch (result) {
                  case Success():
                    authState.login();
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              const Text("Don't have an account?"),
              TextButton(onPressed: () {
                if (widget.onGoToRegister != null) {
                  widget.onGoToRegister!();
                }
              }, child: const Text('Sign Up')),
            ],)
          ],
        ),
      ),
    );
  }
}