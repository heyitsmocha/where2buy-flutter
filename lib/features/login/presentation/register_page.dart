import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:w2b_flutter/core/network_results.dart';
import 'package:w2b_flutter/features/login/logic/register_page_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required this.dio, this.onGoToLogin, this.onRegisterSuccess});

  final Dio dio;
  final Function()? onGoToLogin;
  final Function()? onRegisterSuccess;

  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final RegisterPageController _controller;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _controller = RegisterPageController(widget.dio);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppBar(
            title: const Text('Register'),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back), 
              onPressed: widget.onGoToLogin,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.close), 
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) => (value != null && value.contains('@')) ? null : 'Please enter a valid email',
                  onChanged: (value) => _controller.email = value,
                  autofillHints: const [AutofillHints.email],
                ),
                TextFormField(
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (value) => (value != null && value.isNotEmpty) ? null : 'Please enter your username',
                  onChanged: (value) => _controller.name = value,
                  autofillHints: const [AutofillHints.username],
                ),
                TextFormField(
                  textInputAction: TextInputAction.next,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (value) => (value != null && value.length >= 6) ? null : 'Password must be at least 6 characters',
                  onChanged: (value) => _controller.password = value,
                ),
                TextFormField(
                  textInputAction: TextInputAction.done,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Confirm Password'),
                  validator: (value) {
                    if (value != null && value != _controller.password) {
                      return 'Passwords do not match';
                    }
                    return (value != null && value.length >= 6) ? null : 'Password must be at least 6 characters';
                  },
                  onChanged: (value) => _controller.confirmPassword = value,
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    } 
                    
                    Result<void> result = await _controller.handleRegister();
                    switch (result) {
                      case Success():
                        if (widget.onRegisterSuccess != null) {
                          widget.onRegisterSuccess!();
                        }
                        break;
                      case Failure():
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(result.errorMessage ?? 'Registration failed'),
                          ),
                        );
                        break;
                    }
                  }, 
                  child: const Text('Register')
                ),
              ],
            ))
        ],
      ),
    );
  }
}