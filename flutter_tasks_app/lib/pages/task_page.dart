import 'package:flutter/material.dart';
import 'package:flutter_tasks_app/pages/login_page.dart';
import '../services/task_service.dart';
import '../models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  TaskPageState createState() => TaskPageState();
}

class TaskPageState extends State<TaskPage> {
  List<Task> tasks = [];
  String filter = "all";

  @override
  void initState() {
    super.initState();
    fetchTasks();
    checkLoginStatus();
  }

  // Vérifie si l'utilisateur est connecté
  void checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      fetchTasks();
    }
  }

  Future<void> fetchTasks() async {
    final fetchedTasks = await TaskService.getTasks();
    setState(() {
      tasks = fetchedTasks;
    });
  }

  Future<void> addTask(String title) async {
    final newTask = Task(title: title, done: false);
    await TaskService.addTask(newTask);
    fetchTasks();
  }

/*   Future<void> updateTask(int id, bool done) async {
    await TaskService.updateTask(id, done);
    fetchTasks();
  } */

  Future<void> updateTask(int id, {String? title, bool? done}) async {
    await TaskService.updateTask(id, title: title, done: done);
    fetchTasks();
  }

  void editTaskTitle(BuildContext context, Task task) {
    final controller = TextEditingController(text: task.title);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Modifier la tâche"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: "Nouveau titre",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                updateTask(
                  task.id!,
                  title: controller.text.trim(),
                );
                Navigator.pop(context);
              },
              child: const Text("Enregistrer"),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteTask(int id) async {
    await TaskService.deleteTask(id);
    fetchTasks(); // recharge la liste après suppression
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Supprime le JWT stocké
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false, // supprime toutes les routes précédentes
    );
  }

  bool validateTaskName(String name) {
    // Longueur min et max
    if (name.length < 3 || name.length > 30) return false;

    //  Regex pour autoriser seulement: lettres, chiffres, espaces
    final regex = RegExp(r'^[a-zA-Z0-9À-ÿ ]+$');

    return regex.hasMatch(name);
  }

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    List filteredTasks = tasks;
    if (filter == "done") {
      filteredTasks = tasks.where((t) => t.done == true).toList();
    } else if (filter == "not_done") {
      filteredTasks = tasks.where((t) => t.done == false).toList();
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Colors.lightGreenAccent,
            ),
            onPressed: logout,
          ),
        ],
        title: const Text(
          'LISTE DES TÂCHES',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[600],
        centerTitle: true,
      ),
      body: Column(
        children: [
          //  AJOUT : le menu déroulant de filtrage
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: filter,
              items: const [
                DropdownMenuItem(
                    value: "all", child: Text("Toutes les tâches")),
                DropdownMenuItem(
                    value: "done", child: Text("Tâches terminées")),
                DropdownMenuItem(
                    value: "not_done", child: Text("Tâches non terminées")),
              ],
              onChanged: (value) {
                setState(() {
                  filter = value!;
                });
              },
            ),
          ),

          // LISTE DES TÂCHES FILTRÉES
          Expanded(
            child: ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                final task = filteredTasks[index];
                return Card(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.lightBlue[100 * ((index % 8) + 1)],
                  margin:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 15),
                  child: ListTile(
                    title: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: task.done,
                          onChanged: (bool? value) {
                            if (value != null) {
                              updateTask(task.id!, done: value);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => editTaskTitle(context, task),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Supprimer ?"),
                                content: const Text(
                                    "Voulez-vous vraiment supprimer cette tâche ?"),
                                actions: [
                                  TextButton(
                                    child: const Text("Annuler"),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red),
                                    child: const Text("Supprimer"),
                                    onPressed: () {
                                      Navigator.pop(context); // fermer la popup
                                      deleteTask(
                                          task.id!); // lancer la suppression
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'ajoute une tâche...',
                      prefixIcon: const Icon(Icons.alarm_add_rounded, size: 20),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => controller.clear(),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[700]
                          : Colors.cyanAccent,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.blue[700]
                            : Colors.blue[400],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () {
                    final text = controller.text.trim();

                    if (!validateTaskName(text)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Nom invalide (3–30 caractères, sans caractères spéciaux).",
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return; // ne pas ajouter
                    }

                    addTask(text);
                    controller.clear();
                  },
                  child: const Text('Ajouter'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
