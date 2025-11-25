import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  RegisterPageState createState() => RegisterPageState();
}

// État de la page (contient les données saisies + logique)
class RegisterPageState extends State<RegisterPage> {
  // Contrôleurs pour récupérer le texte des champs
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading =
      false; // Pour afficher une animation de chargement pendant l'inscription
  String? _error; // Message d'erreur si l'inscription échoue

  // la fonction appelée quand l'utilisateur clique sur "S'inscrire"
  void _register() async {
    // Avant d'appeler l'API : activer chargement + supprimer erreur précédente
    setState(() {
      _loading = true;
      _error = null;
    });

    // Appel à l'API via AuthService
    bool success = await AuthService()
        .register(_usernameController.text, _passwordController.text);

    // Une fois la réponse reçue → arrêter le chargement
    setState(() {
      _loading = false;
    });

    if (!mounted) {
      return;
    } // Vérifier si le widget est toujours actif (sécurité Flutter)
    // Afficher un message en bas de l'écran (Snackbar) ou un message d'erreur
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
            // Affiche un loader si _loading = true
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
