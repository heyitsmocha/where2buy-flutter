import 'package:flutter/material.dart';

class PinAnimationWidget extends StatefulWidget {
  /// Widget to display below the animated pin.
  final Widget child;

  /// Provides a way for the parent to access the internal AnimationController.
  final Function(AnimationController animationController) onControllerInitialized;

  const PinAnimationWidget({super.key, required this.onControllerInitialized, required this.child});
  
  @override
  State<StatefulWidget> createState() => _PinAnimationWidgetState();
}

class _PinAnimationWidgetState extends State<PinAnimationWidget>
    with SingleTickerProviderStateMixin {
  // Animation variables
  late AnimationController _pinAnimationController;
  late Animation<double> 
    _xAnimation,
    _yAnimation,
    _rotationAnimation,
    _shadowOpacity,
    _shadowScale;

  Matrix4 get _pinTransform => Matrix4
    .identity()
      ..translate(_xAnimation.value, _yAnimation.value)
      ..rotateZ(_rotationAnimation.value);

  @override
  void initState() {
    super.initState();
    _pinAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    CurvedAnimation curvedAnimation = CurvedAnimation(
      parent: _pinAnimationController,
      curve: Curves.easeOut,
    );

    // Moves the pin up by 20 pixels
    _yAnimation = Tween<double>(begin: 0, end: -20).animate(curvedAnimation,);

    // Moves the pin right by 10 pixels
    _xAnimation = Tween<double>(begin: 0, end: 10).animate(curvedAnimation,);

    // Rotates the pin by 15 degrees
    _rotationAnimation = Tween<double>(begin: 0, end: 0.26).animate(curvedAnimation,);

    _shadowOpacity = Tween<double>(begin: 0.0, end: 0.4).animate(curvedAnimation,);
    _shadowScale = Tween<double>(begin: 0.5, end: 1.2).animate(curvedAnimation,);

    widget.onControllerInitialized(_pinAnimationController);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pinAnimationController,
      builder: (context, child) => Stack(
        children: [
          child!,
          // Pin Icon
          Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: Center(
              child: Transform(
                alignment: Alignment.bottomCenter,
                transform: _pinTransform,
                child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
              ),
            ),
          ),
          // Pin Shadow
          Transform.translate(
            offset: const Offset(0, 4),
            child: Opacity(
              opacity: _shadowOpacity.value,
              child: Center(
                child: Transform.scale(
                  scale: _shadowScale.value,
                  child: Container(
                    width: 20,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: const BorderRadius.all(Radius.elliptical(12, 4)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                        )
                      ]
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _pinAnimationController.dispose();
    super.dispose();
  }
}