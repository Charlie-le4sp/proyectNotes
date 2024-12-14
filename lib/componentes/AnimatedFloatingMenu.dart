 import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

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
    Color buttonColor = Color(int.parse(widget.accentColor.replaceFirst('#', '0xff')));
    Color textColor = ThemeData.estimateBrightnessForColor(buttonColor) == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isOpen) ...[
            FadeInUp(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutCubicEmphasized,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: FloatingActionButton.extended(
                  heroTag: "btnNota",
                  backgroundColor: buttonColor,
                  onPressed: () {
                    _toggleMenu();
                    widget.onNoteTap();
                  },
                  label: Row(
                    children: [
                      Icon(Icons.note_add, color: textColor),
                      const SizedBox(width: 8),
                      Text(
                        'Nueva Nota',
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
            FadeInUp(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutCubicEmphasized,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: FloatingActionButton.extended(
                  heroTag: "btnTarea",
                  backgroundColor: buttonColor,
                  onPressed: () {
                    _toggleMenu();
                    widget.onTaskTap();
                  },
                  label: Row(
                    children: [
                      Icon(Icons.add_task, color: textColor),
                      const SizedBox(width: 8),
                      Text(
                        'Nueva Tarea',
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
          FloatingActionButton.extended(
            backgroundColor: buttonColor,
            onPressed: _toggleMenu,
            label: Row(
              children: [
                RotationTransition(
                  turns: _rotationAnimation,
                  child: Icon(Icons.add, color: textColor),
                ),
                const SizedBox(width: 8),
                Text(
                  'Crear',
                  style: TextStyle(
                    color: textColor,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
