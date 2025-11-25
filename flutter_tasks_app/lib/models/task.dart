class Task {
  final int?
      id; //peut être null si la tâche n'est pas encore enregistrée en base
  final String title;
  final bool done;

  // Constructeur
  Task({this.id, required this.title, required this.done});

  // factory constructor pour créer une Task à partir d'un JSON (Map venant de l'API)
  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        title: json['title'],
        done: json['done'],
      );

  // Convertit un objet Task en JSON (pour l'envoyer à l'API)
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'done': done,
      };
}
