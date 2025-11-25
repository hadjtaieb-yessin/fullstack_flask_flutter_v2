import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/task_page.dart';

//     POINT D’ENTRÉE DU APP

// La fonction main() lance l'application Flutter.
void main() => runApp(const MyApp());

// MyApp est le widget principal de l'application.
// Il configure les thèmes, la navigation, et la page d'accueil.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Tasks App', // Nom de l'application

      // MODE CLAIR
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),

      // MODE SOMBRE
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        cardColor: Colors.grey[900],
        dialogBackgroundColor: Colors.grey[850],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
          ),
        ),
      ),

      // Suivre la préférence système
      themeMode: ThemeMode.system,

      //       PAGE DE DÉBUT
      home: const LoginPage(),
      // ROUTES: Permet de naviguer entre les pages avec Navigator.pushNamed()
      routes: {
        '/register': (context) => const RegisterPage(),
        '/tasks': (context) => const TaskPage(),
      },
    );
  }
}
