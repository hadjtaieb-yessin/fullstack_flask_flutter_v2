/* import 'package:flutter/material.dart';
import 'pages/login_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Tasks App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(),
    );
  }
}
 */

import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/task_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Tasks App',

      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),

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

      home: const LoginPage(),
      routes: {
        '/register': (context) => const RegisterPage(),
        '/tasks': (context) => const TaskPage(),
      },
    );
  }
}
