class Task {
  final int? id;
  final String title;
  final bool done;

  Task({this.id, required this.title, required this.done});

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        title: json['title'],
        done: json['done'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'done': done,
      };
}
