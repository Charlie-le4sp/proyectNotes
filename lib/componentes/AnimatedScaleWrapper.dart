import 'package:flutter/material.dart';

class AnimatedScaleWrapper extends StatefulWidget {
  final Widget child;

  const AnimatedScaleWrapper({super.key, required this.child});

  @override
  State<AnimatedScaleWrapper> createState() => _AnimatedScaleWrapperState();
}

class _AnimatedScaleWrapperState extends State<AnimatedScaleWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Inicializa el AnimationController para manejar la animación.
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300), // Duración de la animación
      vsync: this,
    );

    // Define la animación de escala.
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(
        parent: _controller,
        reverseCurve: Curves.easeIn,
        curve: Curves.decelerate, // Efecto suave de salida.
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) =>
          _controller.forward(), // Inicia la animación al hacer hover.
      onExit: (_) =>
          _controller.reverse(), // Reversa la animación al salir del hover.
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: widget.child, // Widget envuelto.
      ),
    );
  }
}
