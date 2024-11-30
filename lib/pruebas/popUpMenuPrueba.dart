import 'package:flutter/material.dart';

class PopupMenuTestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba de PopupMenuButton'),
      ),
      body: Center(
        child: PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          offset: const Offset(0, 40), // Ajusta la posición
          icon: const Icon(
            Icons.more_vert, // Icono personalizado
            color: Colors.black,
            size: 30,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // Bordes redondeados
          ),
          itemBuilder: (context) => [
            _buildMenuItem(
              context,
              title: 'Hover',
              isSelected: false,
            ),
            _buildMenuItem(
              context,
              title: 'Press',
              isSelected: true, // Este está seleccionado
            ),
            _buildMenuItem(
              context,
              title: 'Loop',
              isSelected: false,
            ),
            _buildMenuItem(
              context,
              title: 'Drag',
              isSelected: false,
            ),
            PopupMenuItem(
              child: Divider(), // Separador
            ),
            _buildMenuItem(
              context,
              title: 'Scroll Speed',
              isSelected: false,
            ),
            _buildMenuItem(
              context,
              title: 'Scroll Transform',
              isSelected: false,
            ),
            _buildMenuItem(
              context,
              title: 'Scroll Variant',
              isSelected: false,
              isDisabled: true, // Deshabilitado
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    BuildContext context, {
    required String title,
    required bool isSelected,
    bool isDisabled = false,
  }) {
    return PopupMenuItem<String>(
      enabled: !isDisabled, // Habilita o deshabilita el ítem
      child: StatefulBuilder(
        builder: (context, setState) {
          bool isHovered = false;

          return MouseRegion(
            onEnter: (_) => setState(() => isHovered = true),
            onExit: (_) => setState(() => isHovered = false),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.blue[400] // Color de selección
                    : (isHovered ? Colors.grey[300] : Colors.transparent),
                borderRadius: BorderRadius.circular(4.0),
              ),
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                title,
                style: TextStyle(
                  color: isDisabled
                      ? Colors.grey
                      : (isSelected ? Colors.white : Colors.black),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
