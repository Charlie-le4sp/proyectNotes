import 'package:flutter/material.dart';

class BounceButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Duration duration;
  final double scaleFactor;

  const BounceButton({
    super.key,
    required this.child,
    required this.onTap,
    this.duration = const Duration(milliseconds: 50), // Duración del efecto
    this.scaleFactor = 0.8, // Factor de escala cuando se hace tap
  });

  @override
  _BounceButtonState createState() => _BounceButtonState();
}

class _BounceButtonState extends State<BounceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation =
        Tween<double>(begin: 1.0, end: widget.scaleFactor).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward(); // Inicia el efecto de escala al tocar
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse(); // Reversa el efecto cuando se deja de tocar
    widget.onTap(); // Llama a la función onTap
  }

  void _handleTapCancel() {
    _controller.reverse(); // Reversa el efecto si se cancela el toque
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click, // Cambia el puntero a cursor en web
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value, // Aplica el efecto de escala
              child: child,
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}
