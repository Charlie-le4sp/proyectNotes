
/*
  import 'package:flutter/material.dart';

class TestInputPage2 extends StatefulWidget {
  const TestInputPage2({super.key});

  @override
  _TestInputPage2State createState() => _TestInputPage2State();
}

class _TestInputPage2State extends State<TestInputPage2> {
  final FocusNode _focus1 = FocusNode();
  final FocusNode _focus2 = FocusNode();
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();

  @override
  void dispose() {
    _focus1.dispose();
    _focus2.dispose();
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Campo 1
              MouseRegion(
                child: TextField(
                  focusNode: _focus1,
                  controller: _controller1,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  autofocus: false, // Asegúrate de deshabilitar el autofocus
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Campo 1',
                  ),
                  onEditingComplete: () {
                    _focus1.unfocus(); // Quita el foco actual
                    Future.delayed(Duration.zero, () {
                      FocusScope.of(context).requestFocus(
                          _focus2); // Mueve el foco al siguiente campo
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Campo 2
              MouseRegion(
                child: TextField(
                  focusNode: _focus2,
                  controller: _controller2,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  autofocus: false, // Asegúrate de deshabilitar el autofocus
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Campo 2',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Imprime los valores de los campos
                  print('Campo 1: ${_controller1.text}');
                  print('Campo 2: ${_controller2.text}');
                },
                child: const Text('Enviar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

*/
