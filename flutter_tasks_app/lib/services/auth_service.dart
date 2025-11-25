import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final _storage =
      const FlutterSecureStorage(); // Stockage sécurisé pour garder le token JWT même après fermeture de l'app.
  final String baseUrl = "http://localhost:5000";

  // Register
  Future<bool> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );
    return response.statusCode == 201;
  }

  // Login
  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );
    // Si le serveur renvoie 200 = identifiants corrects.
    if (response.statusCode == 200) {
      final data =
          json.decode(response.body); // On récupère le token envoyé par l'API.
      await _storage.write(
          key: 'token',
          value: data[
              'access_token']); // On sauvegarde le token dans le stockage sécurisé. Cela permet à l'utilisateur de rester connecté.
      return true;
    }
    return false;
  }

  // Get token
  Future<String?> getToken() async {
    return await _storage.read(
        key: 'token'); // Lire le token stocké dans FlutterSecureStorage.
  }
}
