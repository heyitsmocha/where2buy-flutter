import 'package:flutter/material.dart';

/// A simple widget that conditionally builds its child based on a boolean condition. <br>
/// This is a replacement for using if statements in the widget tree (e.g. `if (condition) Widget()`). <br><br>
/// Note that the widget passed to [ifTrue] will not be built at all if [condition] is false. To keep the state of the widget even when it's not shown, consider using [Visibility] with `maintainState: true` instead.
class ShowWhen extends StatelessWidget {
  final bool condition;
  final WidgetBuilder ifTrue;

  const ShowWhen({super.key, required this.condition, required this.ifTrue});

  @override
  Widget build(BuildContext context) => condition ? ifTrue(context) : const SizedBox.shrink();
}