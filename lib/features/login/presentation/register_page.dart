import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, this.onGoToLogin, this.onRegisterSuccess});

  final Function()? onGoToLogin;
  final Function()? onRegisterSuccess;

  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppBar(
          title: const Text('Register'),
          centerTitle: true,
          automaticallyImplyLeading: false,
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
        TextButton(
          onPressed: () {
            if (widget.onGoToLogin != null) {
              widget.onGoToLogin!();
            }
          },
          child: const Text('Go to Login'),
        ),
      ],
    );
  }

}