import 'package:flutter/material.dart';

class CustomPopupMenu extends StatelessWidget {
  const CustomPopupMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300], // Fondo similar a la imagen
      appBar: AppBar(
        title: const Text("Profile Menu Example"),
        centerTitle: true,
        backgroundColor: Colors.grey[700],
        actions: [
          GestureDetector(
            onTap: () {
              // Mostrar el menú emergente debajo de la foto de perfil
              showDialog(
                context: context,
                barrierColor: Colors.transparent, // Fondo transparente
                builder: (BuildContext context) {
                  return ProfileMenu();
                },
              );
            },
            child: Container(
              margin:
                  const EdgeInsets.only(right: 16), // Espaciado a la derecha
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: const DecorationImage(
                  image: NetworkImage('https://i.pravatar.cc/300'),
                  fit: BoxFit.cover,
                ),
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          "Haz clic en la imagen de perfil en el AppBar",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

class ProfileMenu extends StatelessWidget {
  ProfileMenu({super.key});

  final List<MenuOption> menuOptions = [
    MenuOption(
      text: "opcion 1",
      icon: Icons.edit,
      onTap: () {
        // Acción específica para opción 1
        print('Opción 1 seleccionada');
      },
    ),
    MenuOption(
      text: "opcion 2",
      icon: Icons.bookmark,
      onTap: () {
        // Acción específica para opción 2
        print('Opción 2 seleccionada');
      },
    ),
    MenuOption(
      text: "opcion 3",
      icon: Icons.check_circle,
      onTap: () {
        // Acción específica para opción 3
        print('Opción 3 seleccionada');
      },
    ),
    MenuOption(
      text: "opcion 4",
      icon: Icons.folder,
      onTap: () {
        // Acción específica para opción 4
        print('Opción 4 seleccionada');
      },
    ),
    MenuOption(
      text: "opcion 5",
      icon: Icons.refresh,
      onTap: () {
        // Acción específica para opción 5
        print('Opción 5 seleccionada');
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 50, // Ajusta según el tamaño del AppBar
          right: 20, // Posicionamiento similar al ejemplo
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: menuOptions.map((option) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 4.0), // Espaciado vertical
                    child: HoverMenuOption(
                      text: option.text,
                      icon: option.icon,
                      onTap: option.onTap, // Usar la función onTap específica
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MenuOption {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const MenuOption({
    required this.text,
    required this.icon,
    required this.onTap,
  });
}

class HoverMenuOption extends StatefulWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const HoverMenuOption({
    required this.text,
    required this.icon,
    required this.onTap,
    super.key,
  });

  @override
  State<HoverMenuOption> createState() => _HoverMenuOptionState();
}

class _HoverMenuOptionState extends State<HoverMenuOption> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) {
          setState(() {
            isHovered = true;
          });
        },
        onExit: (_) {
          setState(() {
            isHovered = false;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: isHovered ? Colors.blue.shade100 : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.text,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              Icon(
                widget.icon,
                color: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
