import 'package:flutter/material.dart';

class Choose extends StatelessWidget {
  final Widget ifTrue;
  final Widget ifFalse;
  final bool condition;
  
  const Choose({
    super.key,
    required this.condition,
    required this.ifTrue,
    required this.ifFalse,
  });

  @override
  Widget build(BuildContext context) {
    return condition ? ifTrue : ifFalse;
  }
}