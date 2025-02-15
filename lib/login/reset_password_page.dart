import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formkeyLogin = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String errorMessage = '';
  String successMessage = '';

  Future<void> resetPassword() async {
    if (_formkeyLogin.currentState?.validate() ?? false) {
      try {
        await _auth.sendPasswordResetEmail(
          email: emailController.text,
        );
        setState(() {
          successMessage =
              'A password reset link has been sent to ${emailController.text}';
          errorMessage = '';
        });
      } on FirebaseAuthException catch (e) {
        setState(() {
          errorMessage = e.message ?? 'An error occurred';
          successMessage = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formkeyLogin,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: resetPassword,
                child: const Text('Reset Password'),
              ),
              if (successMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    successMessage,
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
