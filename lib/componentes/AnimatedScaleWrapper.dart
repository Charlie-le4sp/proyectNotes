import 'package:flutter/material.dart';

class AnimatedScaleWrapper extends StatefulWidget {
  final Widget child;
  final Color? initialColor;
  final Color? hoverColor;

  const AnimatedScaleWrapper({
    super.key,
    required this.child,
    this.initialColor,
    this.hoverColor,
  });

  @override
  State<AnimatedScaleWrapper> createState() => _AnimatedScaleWrapperState();
}

class _AnimatedScaleWrapperState extends State<AnimatedScaleWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool isHovered = false;

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
      onEnter: (_) {
        _controller.forward();
        if (widget.hoverColor != null) {
          setState(() {
            isHovered = true;
          });
        }
      },
      onExit: (_) {
        _controller.reverse();
        if (widget.initialColor != null) {
          setState(() {
            isHovered = false;
          });
        }
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              color: isHovered ? widget.hoverColor : widget.initialColor,
              child: child,
            ),
          );
        },
        child: widget.child, // Widget envuelto.
      ),
    );
  }
}
