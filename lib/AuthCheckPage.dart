import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'paginaInicio.dart';
import 'login android y web autentication/login_page.dart';

class AuthCheckPage extends StatefulWidget {
  @override
  _AuthCheckPageState createState() => _AuthCheckPageState();
}

class _AuthCheckPageState extends State<AuthCheckPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showLoginDialog();
        });
      } else {
        // Redirigir al contenido si el usuario está autenticado
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => paginaInicio()),
        );
      }
    } catch (e) {
      print("Error al verificar autenticación: $e");
      _showErrorDialog(
          "Hubo un problema al verificar la autenticación. Inténtalo de nuevo.");
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Iniciar sesión'),
          content: Text(
              'Por favor, inicia sesión para acceder a tus notas y listas.'),
          actions: <Widget>[
            TextButton(
              child: Text('Iniciar sesión'),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
