import 'package:flutter/material.dart';
import 'package:flutter_tasks_app/pages/register_page.dart';
import '../services/auth_service.dart';
import 'task_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  LoginPageState createState() => LoginPageState();
}

// État associé à la page Login
class LoginPageState extends State<LoginPage> {
  // Contrôleurs pour récupérer le texte des champs
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading =
      false; // Variable pour afficher un indicateur de chargement lors de la connexion
  String? _error; // Variable pour afficher un message d'erreur si login échoue

  // la méthode appelée lorsqu'on clique sur "Se connecter"
  void _login() async {
    setState(() {
      // On active le chargement et on efface l'erreur précédente
      _loading = true;
      _error = null;
    });

    bool success =
        await AuthService() // On appelle le service d'authentification
            .login(
                _usernameController.text,
                _passwordController
                    .text); // Cette méthode retourne true si connexion réussie

    setState(() {
      // Une fois la réponse reçue, on désactive le chargement
      _loading = false;
    });

    if (success) {
      // Si la connexion a réussi, on navigue vers la page des tâches
      if (!mounted) return;
      Navigator.pushReplacement(
        // Remplace la page actuelle par TaskPage
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
            // Champ texte → nom d'utilisateur
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: "Nom d'utilisateur"),
            ),
            // Champ texte → mot de passe
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Mot de passe"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            _loading // Si _loading = true → afficher un loader, sinon afficher le bouton
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: Text("Se connecter"),
                  ),
            if (_error != null) ...[
              SizedBox(height: 20),
              Text(_error!, style: TextStyle(color: Colors.red)),
            ],
            // Le lien pour aller à la page d'inscription
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
