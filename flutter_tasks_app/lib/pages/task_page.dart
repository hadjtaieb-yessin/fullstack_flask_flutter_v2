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
  String filter = "all"; // Filtre sélectionné (toutes / faites / non faites)
  int currentPage = 1;
  int totalPages = 2;
  final int limit = 4;

  @override
  void initState() {
    super.initState();
    loadPaginatedTasks();
    checkLoginStatus(); // Vérifier si l'utilisateur est connecté
  }

  // Vérifie si l'utilisateur est connecté, si non, redirection vers login
  void checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      loadPaginatedTasks();
    }
  }

  Future<void> loadPaginatedTasks() async {
    final data = await TaskService.getTasks(currentPage, limit);

    setState(() {
      tasks = data["tasks"];
      totalPages = data["pages"];
    });
  }

  // Ajouter une nouvelle tâche
  Future<void> addTask(String title) async {
    final newTask = Task(title: title, done: false);
    await TaskService.addTask(newTask);

    loadPaginatedTasks();
  }

  // Mettre à jour une tâche (title ou done)
  Future<void> updateTask(int id, {String? title, bool? done}) async {
    await TaskService.updateTask(id, title: title, done: done);
    loadPaginatedTasks();
  }

  // Modifier le titre d’une tâche via une pop-up
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

  // Supprimer une tâche
  Future<void> deleteTask(int id) async {
    await TaskService.deleteTask(id);
    await loadPaginatedTasks();
  }

  // Déconnexion
  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Supprime le JWT stocké
    if (!mounted) return;
    // On efface tout l’historique et on revient au login
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false, // supprime toutes les routes précédentes
    );
  }

  // Vérifie si le nom de la tâche est valide (controle de saisie)
  bool validateTaskName(String name) {
    // Longueur min et max
    if (name.length < 3 || name.length > 30) return false;

    //  Regex pour autoriser seulement: lettres( é,à,ç ... inclus ), chiffres, espaces
    final regex = RegExp(r'^[a-zA-Z0-9À-ÿ ]+$');

    return regex.hasMatch(name);
  }

  void showAddTaskDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter une nouvelle tâche'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Nom de la tâche',
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Annuler'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('Ajouter'),
              onPressed: () {
                final text = controller.text.trim();

                if (!validateTaskName(text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          "Nom invalide (3–30 caractères, sans caractères spéciaux)."),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                addTask(text);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Bar en haut
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
      // Body de la page
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

          // LISTE DES TÂCHES
          Expanded(
            child: tasks.isEmpty
                ? const Center(child: Text("Aucune tâche trouvée"))
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];

                      // Filtrer
                      if (filter == 'done' && !task.done) {
                        return const SizedBox.shrink();
                      }
                      if (filter == 'not_done' && task.done) {
                        return const SizedBox.shrink();
                      }

                      return Card(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.lightBlue[100 * ((index % 8) + 1)],
                        margin: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 17),
                        child: ListTile(
                          title: Text(
                            task.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontStyle: FontStyle.italic,
                            ),
                          ),

                          // ACTIONS
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // CHECKBOX
                              Checkbox(
                                value: task.done,
                                onChanged: (value) async {
                                  if (value != null) {
                                    await updateTask(task.id!, done: value);
                                    await loadPaginatedTasks();
                                  }
                                },
                              ),

                              // EDIT
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => editTaskTitle(context, task),
                              ),

                              // DELETE
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) {
                                      return AlertDialog(
                                        title: const Text("Confirmer"),
                                        content: const Text(
                                            "Voulez-vous vraiment supprimer cette tâche ?"),
                                        actions: [
                                          TextButton(
                                            child: const Text("Annuler"),
                                            onPressed: () => Navigator.pop(ctx),
                                          ),
                                          TextButton(
                                            child: const Text("Supprimer",
                                                style: TextStyle(
                                                    color: Colors.red)),
                                            onPressed: () async {
                                              Navigator.pop(
                                                  ctx); // fermer modal
                                              await deleteTask(task.id!);
                                            },
                                          ),
                                        ],
                                      );
                                    },
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: currentPage > 1
                    ? () {
                        currentPage--;
                        loadPaginatedTasks();
                      }
                    : null,
                child: const Text("Précédent"),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text("Page $currentPage / $totalPages"),
              ),
              TextButton(
                onPressed: currentPage < totalPages
                    ? () {
                        currentPage++;
                        loadPaginatedTasks();
                      }
                    : null,
                child: const Text("Suivant"),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, size: 30),
        onPressed: () => showAddTaskDialog(context),
      ),
    );
  }
}
