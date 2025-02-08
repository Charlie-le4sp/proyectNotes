import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BounceTabBar extends StatefulWidget {
  const BounceTabBar({super.key});

  @override
  _BounceTabBarState createState() => _BounceTabBarState();
}

class _BounceTabBarState extends State<BounceTabBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("TabBar con Flutter Animate"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // TabBar
          Stack(
            children: [
              // Indicador con animación de rebote
              Align(
                alignment: Alignment(
                  -1.0 + (_selectedIndex * (2 / 3)),
                  0.0,
                ),
                child: Container(
                  width: screenWidth / 4 - 20,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ).animate().scale(duration: 1000.ms, curve: Curves.elasticOut),
              ),
              // Pestañas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(4, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    child: Container(
                      width: screenWidth / 4 - 20,
                      alignment: Alignment.center,
                      child: Text(
                        [
                          "notas",
                          "tareas",
                          "importantes",
                          "colecciones"
                        ][index],
                        style: TextStyle(
                          fontSize: 16,
                          color: _selectedIndex == index
                              ? Colors.white
                              : Colors.black,
                          fontWeight: _selectedIndex == index
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: Text(
                [
                  "Notas",
                  "Tareas",
                  "Importantes",
                  "Colecciones"
                ][_selectedIndex],
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
