import 'package:flutter/material.dart';

class BaseLayout extends StatelessWidget {
  final Widget child;

  /// A simple base layout that centers its child and adds padding of 8.0 on all sides.
  const BaseLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: child,
      ),
    );
  }
}