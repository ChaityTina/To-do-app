enum Priority { low, medium, high }

class Todo {
  String title;
  String place;
  DateTime dateTime;
  Priority priority;
  bool isDone;

  Todo({
    required this.title,
    required this.place,
    required this.dateTime,
    required this.priority,
    this.isDone = false,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'place': place,
    'dateTime': dateTime.toIso8601String(),
    'priority': priority.index,
    'isDone': isDone,
  };

  factory Todo.fromMap(Map map) => Todo(
    title: map['title'],
    place: map['place'],
    dateTime: DateTime.parse(map['dateTime']),
    priority: Priority.values[map['priority']],
    isDone: map['isDone'],
  );
}
