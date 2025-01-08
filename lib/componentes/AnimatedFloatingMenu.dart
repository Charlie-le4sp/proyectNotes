import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart'
    as animate_do; // Prefijo para animate_do
import 'package:bounce/bounce.dart' as bounce_pkg;
import 'package:notes_app/languajeCode/languaje_provider.dart';
import 'package:provider/provider.dart'; // Prefijo para bounce

class AnimatedFloatingMenu extends StatefulWidget {
  final String accentColor;
  final Function() onNoteTap;
  final Function() onTaskTap;

  const AnimatedFloatingMenu({
    Key? key,
    required this.accentColor,
    required this.onNoteTap,
    required this.onTaskTap,
  }) : super(key: key);

  @override
  State<AnimatedFloatingMenu> createState() => _AnimatedFloatingMenuState();
}

class _AnimatedFloatingMenuState extends State<AnimatedFloatingMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    Color buttonColor =
        Color(int.parse(widget.accentColor.replaceFirst('#', '0xff')));
    Color textColor =
        ThemeData.estimateBrightnessForColor(buttonColor) == Brightness.dark
            ? Colors.white
            : Colors.black;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isOpen) ...[
            // Botón Nueva Nota con animación Bounce
            SizedBox(
              height: 10,
            ),
            animate_do.FadeInUp(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutCubicEmphasized,
              child: bounce_pkg.Bounce(
                cursor: SystemMouseCursors.click,
                duration: const Duration(milliseconds: 250),
                onTap: () {
                  _toggleMenu();
                  widget.onNoteTap();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  decoration: BoxDecoration(
                    color: buttonColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.note_add, color: textColor),
                      const SizedBox(width: 8),
                      Text(
                        languageProvider.translate('notes'),
                        style: TextStyle(
                          color: textColor,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            // Botón Nueva Tarea con animación Bounce
            animate_do.FadeInUp(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutCubicEmphasized,
              child: bounce_pkg.Bounce(
                cursor: SystemMouseCursors.click,
                duration: const Duration(milliseconds: 250),
                onTap: () {
                  _toggleMenu();
                  widget.onTaskTap();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  decoration: BoxDecoration(
                    color: buttonColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_task, color: textColor),
                      const SizedBox(width: 8),
                      Text(
                        languageProvider.translate('tasks'),
                        style: TextStyle(
                          color: textColor,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          SizedBox(
            height: 10,
          ),
          // Botón Principal con Bounce Animation y Sombra
          bounce_pkg.Bounce(
            cursor: SystemMouseCursors.click,
            duration: const Duration(milliseconds: 250),
            onTap: _toggleMenu,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: buttonColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), // Color de la sombra
                    blurRadius: 8, // Difuminado de la sombra
                    offset: const Offset(0, 4), // Desplazamiento
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RotationTransition(
                    turns: _rotationAnimation,
                    child: Icon(Icons.add, color: textColor),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    languageProvider.translate('create'),
                    style: TextStyle(
                      color: textColor,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
