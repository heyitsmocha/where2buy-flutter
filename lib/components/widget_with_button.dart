import 'package:flutter/material.dart';

/// A widget that wraps a child widget and adds a floating action button at the bottom right corner
class WidgetWithButton extends StatefulWidget {
  const WidgetWithButton({
    super.key,
    required this.child,
    required this.onPressed,
    required this.buttonIcon,
    this.heroTag,
  });

  final VoidCallback onPressed;
  final Widget child;
  final Widget buttonIcon;
  final Object? heroTag;

  @override
  State<WidgetWithButton> createState() => _WidgetWithButtonState();
}

class _WidgetWithButtonState extends State<WidgetWithButton> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          bottom: 10,
          right: 10,
          child: FloatingActionButton(
            onPressed: widget.onPressed,
            heroTag: widget.heroTag,
            child: widget.buttonIcon,
          ),
        ),
      ],
    );
  }
}