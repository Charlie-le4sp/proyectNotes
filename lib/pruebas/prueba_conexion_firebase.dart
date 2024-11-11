import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class pagina_conexion extends StatefulWidget {
  const pagina_conexion({super.key});

  @override
  _pagina_conexionState createState() => _pagina_conexionState();
}

class _pagina_conexionState extends State<pagina_conexion> {
  final _formKeyLoginPrueba = GlobalKey<FormState>();
  final _controller = TextEditingController();

  void _sendDataToFirestore() async {
    if (_formKeyLoginPrueba.currentState!.validate()) {
      String data = _controller.text;
      // Añadir dato a Firestore
      await FirebaseFirestore.instance.collection('datos').add({
        'campo': data,
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos enviados a Firestore')),
      );
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enviar datos a Firestore'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKeyLoginPrueba,
          child: Column(
            children: [
              TextFormField(
                controller: _controller,
                decoration: const InputDecoration(labelText: 'Ingrese un dato'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese algún dato';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _sendDataToFirestore,
                child: const Text('Enviar a Firestore'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
