import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/componentes/AnimatedScaleWrapper.dart';

class pruebaAnimatedWrapper extends StatelessWidget {
  const pruebaAnimatedWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Material App Bar'),
        ),
        body: Center(
          child: Bounce(
            cursor: SystemMouseCursors.click,
            duration: const Duration(milliseconds: 120),
            onTap: () {},
            child: AnimatedScaleWrapper(
              child: Container(
                height: 100,
                width: 170,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(17),
                    color: Colors.amber),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
