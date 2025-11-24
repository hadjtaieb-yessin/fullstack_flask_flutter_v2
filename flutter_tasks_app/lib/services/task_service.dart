// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import 'auth_service.dart';

class TaskService {
  static const String baseUrl = 'http://localhost:5000/tasks';

  static Future<List<Task>> getTasks() async {
    try {
      final token = await AuthService().getToken();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List jsonData = json.decode(response.body);
        return jsonData.map((e) => Task.fromJson(e)).toList();
      } else {
        print('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur: $e');
    }
    return [];
  }

  static Future<void> addTask(Task task) async {
    try {
      final token = await AuthService().getToken();
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(task.toJson()),
      );
      if (response.statusCode != 201) {
        print('Erreur ajout tâche: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur: $e');
    }
  }

  static Future<void> updateTask(int id, {String? title, bool? done}) async {
    try {
      final token = await AuthService().getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          if (title != null) "title": title,
          if (done != null) "done": done,
        }),
      );

      if (response.statusCode != 200) {
        print('Erreur mise à jour: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur: $e');
    }
  }

  static Future<void> deleteTask(int id) async {
    try {
      final token = await AuthService().getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode != 200) {
        print('Erreur suppression tâche: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur: $e');
    }
  }
}
