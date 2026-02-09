import 'package:flutter/material.dart';

class MapSecondaryButton extends StatelessWidget {
  const MapSecondaryButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
  });

  final VoidCallback? onPressed;
  final Widget icon;
  final String? tooltip;

  ButtonStyle _secondaryButtonStyle(BuildContext context) {
    return onPressed == null
    ? ButtonStyle(
        // Semi-transparent background color
        backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onInverseSurface.withOpacity(0.8)),
        iconColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onSurface.withOpacity(0.38))
      )
    : ButtonStyle(
      // Solid background color
      backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.inversePrimary),
      iconColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary)
      ); 
  }

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      style: _secondaryButtonStyle(context),
      onPressed: onPressed,
      icon: icon,
      tooltip: tooltip,
    );
  }
}