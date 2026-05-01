import 'package:flutter/material.dart';

/// A simple widget that chooses between two widgets to display based on a boolean condition. This is useful for showing loading states, empty states, or toggling between different views without having to write if-else logic directly in the build method of the parent widget.
/// 
/// Usage:
/// ```dart
/// Choose(
///   condition: isLoading,
///   ifTrue: (context) => CircularProgressIndicator(),
///   ifFalse: (context) => Text('Data Loaded'),
/// );
/// ```
class Choose extends StatelessWidget {
  // Use WidgetBuilder instead of direct Widget to ensure the latest value is always used when the widget is built, especially if the condition changes and triggers a rebuild
  /// The widget to display when the condition is true
  final WidgetBuilder ifTrue;
  /// The widget to display when the condition is false
  final WidgetBuilder ifFalse;
  /// The condition to evaluate to determine which widget to display
  final bool condition;
  
  const Choose({
    super.key,
    required this.condition,
    required this.ifTrue,
    required this.ifFalse,
  });

  @override
  Widget build(BuildContext context) {
    return condition ? ifTrue(context) : ifFalse(context);
  }
}