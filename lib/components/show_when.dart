import 'package:flutter/material.dart';

/// A simple widget that conditionally shows its child based on a boolean condition. <br>
/// This is a replacement for using if statements in the widget tree (e.g., `if (condition) Widget()`).
class ShowWhen extends StatelessWidget {
  final bool condition;
  final WidgetBuilder ifTrue;

  const ShowWhen({super.key, required this.condition, required this.ifTrue});

  @override
  Widget build(BuildContext context) => condition ? ifTrue(context) : const SizedBox.shrink();
}