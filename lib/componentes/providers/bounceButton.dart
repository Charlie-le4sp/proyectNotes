import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';

class BounceButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Duration inDuration; // Duración de la entrada
  final Duration outDuration; // Duración de la salida con rebote
  final double scaleFactor; // Escala cuando se toca el botón

  const BounceButton({
    super.key,
    required this.child,
    required this.onTap,
    this.inDuration = const Duration(milliseconds: 80), // Entrada rápida
    this.outDuration = const Duration(milliseconds: 400), // Salida con rebote
    this.scaleFactor = 0.85,
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
      duration: widget.inDuration, // Entrada rápida
      reverseDuration: widget.outDuration, // Salida con rebote
    );

    // Configuramos la escala con una curva bounceOut
    _scaleAnimation =
        Tween<double>(begin: 1.0, end: widget.scaleFactor).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.decelerate, // Entrada rápida y suave
        reverseCurve: Curves.bounceOut, // Salida con efecto rebote
      ),
    );
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward(); // Al tocar, reduce la escala
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse(); // Al soltar, hace la animación con rebote
    widget.onTap(); // Llama a la función onTap
  }

  void _handleTapCancel() {
    _controller
        .reverse(); // Si se cancela, también hace la animación con rebote
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value, // Aplica la escala
              child: child,
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}

class PruebaBoton extends StatelessWidget {
  const PruebaBoton({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bounce Button Example',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Bounce Button Animation'),
        ),
        body: Center(
          child: Bounce(
            cursor: SystemMouseCursors.click,
            duration: const Duration(milliseconds: 110),
            onTap: () {
              print("Botón presionado");
            },
            child: Container(
              height: 80,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Bounce!',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
