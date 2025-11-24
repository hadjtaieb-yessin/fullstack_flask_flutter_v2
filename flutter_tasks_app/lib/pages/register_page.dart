import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  void _register() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    bool success = await AuthService()
        .register(_usernameController.text, _passwordController.text);

    setState(() {
      _loading = false;
    });

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Inscription réussie")));
      Navigator.pop(context); // revenir à la page login
    } else {
      setState(() {
        _error = "Échec de l'inscription";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inscription")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: "Nom d'utilisateur"),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Mot de passe"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            _loading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _register,
                    child: Text("S'inscrire"),
                  ),
            if (_error != null) ...[
              SizedBox(height: 20),
              Text(_error!, style: TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
