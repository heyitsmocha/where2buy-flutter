import 'package:flutter/material.dart';

class BaseLayout extends StatelessWidget {
  final Widget child;
  final bool topPadding, bottomPadding, leftPadding, rightPadding;

  /// A simple base layout that centers its child and adds padding of 8.0 on all sides.
  /// The top, bottom, left, and right padding can be optionally disabled by setting [topPadding], [bottomPadding], [leftPadding], and [rightPadding] to false.
  const BaseLayout({super.key, required this.child, this.topPadding = true, this.bottomPadding = true, this.leftPadding = true, this.rightPadding = true});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          top: topPadding ? 8.0 : 0.0,
          bottom: bottomPadding ? 8.0 : 0.0,
          left: leftPadding ? 8.0 : 0.0,
          right: rightPadding ? 8.0 : 0.0,
        ),
        child: child,
      ),
    );
  }
}