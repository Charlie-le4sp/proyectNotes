import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color normalColor;
  final Color pressedColor;
  final double width;
  final double height;

  CustomButton({
    required this.onPressed,
    required this.child,
    this.normalColor = Colors.white,
    this.pressedColor = Colors.black,
    this.width = 200,
    this.height = 50,
  });

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  late Color _buttonColor;

  @override
  void initState() {
    super.initState();
    _buttonColor = widget.normalColor; // Color inicial del botón
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _buttonColor = widget.pressedColor; // Cambia de color cuando se presiona
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _buttonColor = widget.normalColor; // Vuelve al color original al soltar
    });
    widget.onPressed(); // Ejecuta la acción pasada en onPressed
  }

  void _onTapCancel() {
    setState(() {
      _buttonColor =
          widget.normalColor; // Vuelve al color original si se cancela
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click, // Cambia el cursor a mano en web
      child: GestureDetector(
        onTapDown: _onTapDown, // Detecta cuando se presiona
        onTapUp: _onTapUp, // Detecta cuando se suelta
        onTapCancel: _onTapCancel, // Detecta si se cancela el toque
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: _buttonColor,
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: widget.child, // El contenido del botón (texto, íconos, etc.)
        ),
      ),
    );
  }
}
