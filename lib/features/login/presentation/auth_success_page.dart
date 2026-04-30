import 'dart:async';

import 'package:flutter/material.dart';

class AuthSuccessPage extends StatefulWidget {
  final ValueNotifier<String> dataNotifier;
  final Function(String)? onAuthSuccess;

  const AuthSuccessPage({super.key, required this.dataNotifier, this.onAuthSuccess});

  @override
  State<StatefulWidget> createState() => _AuthSuccessPageState();
}

class _AuthSuccessPageState extends State<AuthSuccessPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Call the onAuthSuccess callback if provided
      if (widget.onAuthSuccess != null) {
        widget.onAuthSuccess!(widget.dataNotifier.value);
      }
    });

    // Start countdown to automatically pop the bottom sheet after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.close), 
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
        const SizedBox(height: 16),
        ValueListenableBuilder<String>(
          valueListenable: widget.dataNotifier,
          builder: (context, value, child) {
            return Text(
              value == "Login" ? "Logged in successfully!" : "Account created successfully!",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            );
          },
        ),
        const SizedBox(height: 16,),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(), 
          child: const Text('Proceed')
        ),
        const SizedBox(height: 16,),
        const Text(
          'This page will close automatically. Alternatively, you can press the proceed button, tap outside this page or slide it down to close manually.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}