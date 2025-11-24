import 'package:flutter/material.dart';
import 'package:flutter_tasks_app/pages/register_page.dart';
import '../services/auth_service.dart';
import 'task_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  void _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    bool success = await AuthService()
        .login(_usernameController.text, _passwordController.text);

    setState(() {
      _loading = false;
    });

    if (success) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => TaskPage()),
      );
    } else {
      setState(() {
        _error = "Échec de l'authentification";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
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
                    onPressed: _login,
                    child: Text("Se connecter"),
                  ),
            if (_error != null) ...[
              SizedBox(height: 20),
              Text(_error!, style: TextStyle(color: Colors.red)),
            ],
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                );
              },
              child: const Text("Pas de compte ? S'inscrire"),
            )
          ],
        ),
      ),
    );
  }
}
