import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final box = Hive.box('todos');
  final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  List<Todo> todos = [];
  List<Todo> filteredTodos = [];

  final titleController = TextEditingController();
  final placeController = TextEditingController();

  Priority selectedPriority = Priority.medium;
  DateTime? selectedDateTime;

  String searchText = "";
  Priority? filterPriority;

  @override
  void initState() {
    super.initState();
    initNotifications();
    loadTodos();
  }

  // ===============================
  // Hive Storage
  // ===============================
  void loadTodos() {
    final data = box.get('tasks', defaultValue: []) as List;
    todos = data
        .map((e) => Todo.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    applyFilters();
  }

  void saveTodos() {
    box.put('tasks', todos.map((e) => e.toMap()).toList());
  }

  // ===============================
  // Notifications
  // ===============================
  void initNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await notifications.initialize(
      const InitializationSettings(android: android),
    );
  }

  Future<void> scheduleNotification(Todo todo) async {
    await notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      "Task Reminder",
      todo.title,
      const NotificationDetails(
        android: AndroidNotificationDetails('todo', 'Tasks'),
      ),
    );
  }

  // ===============================
  // Add / Edit Task
  // ===============================
  void addOrEditTodo({int? index}) {
    if (titleController.text.isEmpty ||
        placeController.text.isEmpty ||
        selectedDateTime == null)
      return;

    final todo = Todo(
      title: titleController.text,
      place: placeController.text,
      dateTime: selectedDateTime!,
      priority: selectedPriority,
    );

    setState(() {
      if (index == null) {
        todos.add(todo);
        scheduleNotification(todo);
      } else {
        todos[index] = todo;
      }

      saveTodos();
      applyFilters();
    });

    Navigator.pop(context);
  }

  // ===============================
  // Filters & Search
  // ===============================
  void applyFilters() {
    filteredTodos = todos.where((t) {
      final matchSearch = t.title.toLowerCase().contains(
        searchText.toLowerCase(),
      );

      final matchPriority =
          filterPriority == null || t.priority == filterPriority;

      return matchSearch && matchPriority;
    }).toList();

    filteredTodos.sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  // ===============================
  // Bottom Sheet Form
  // ===============================
  void openForm({int? index}) {
    if (index != null) {
      final t = filteredTodos[index];
      titleController.text = t.title;
      placeController.text = t.place;
      selectedPriority = t.priority;
      selectedDateTime = t.dateTime;
    } else {
      titleController.clear();
      placeController.clear();
      selectedDateTime = null;
      selectedPriority = Priority.medium;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: placeController,
              decoration: const InputDecoration(labelText: "Place"),
            ),
            DropdownButtonFormField(
              value: selectedPriority,
              items: Priority.values
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e.name.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (v) => selectedPriority = v!,
            ),
            ElevatedButton(
              child: const Text("Pick Date & Time"),
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );

                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                if (date != null && time != null) {
                  selectedDateTime = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    time.hour,
                    time.minute,
                  );
                }
              },
            ),
            ElevatedButton(
              onPressed: () => addOrEditTodo(index: index),
              child: Text(index == null ? "Add Task" : "Update Task"),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================
  // UI Helpers
  // ===============================
  Color priorityColor(Priority p) {
    switch (p) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    int doneCount = todos.where((t) => t.isDone).length;
    double progress = todos.isEmpty ? 0 : doneCount / todos.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Manager"),
        actions: [
          PopupMenuButton<Priority?>(
            onSelected: (value) {
              setState(() {
                filterPriority = value;
                applyFilters();
              });
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: null, child: Text("All")),
              const PopupMenuItem(value: Priority.high, child: Text("High")),
              const PopupMenuItem(
                value: Priority.medium,
                child: Text("Medium"),
              ),
              const PopupMenuItem(value: Priority.low, child: Text("Low")),
            ],
          ),
        ],
      ),

      // ===============================
      // BODY
      // ===============================
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search task",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) {
                setState(() {
                  searchText = v;
                  applyFilters();
                });
              },
            ),
          ),

          LinearProgressIndicator(value: progress),

          Expanded(
            child: filteredTodos.isEmpty
                ? const Center(child: Text("No tasks"))
                : ListView.builder(
                    itemCount: filteredTodos.length,
                    itemBuilder: (context, index) {
                      final todo = filteredTodos[index];

                      return Dismissible(
                        key: Key(todo.title),
                        onDismissed: (_) {
                          setState(() {
                            todos.remove(todo);
                            saveTodos();
                            applyFilters();
                          });
                        },
                        child: Card(
                          child: ListTile(
                            leading: Checkbox(
                              value: todo.isDone,
                              onChanged: (_) {
                                setState(() {
                                  todo.isDone = !todo.isDone;
                                  saveTodos();
                                });
                              },
                            ),
                            title: Text(todo.title),
                            subtitle: Text(
                              "${todo.place}\n${DateFormat('dd MMM yyyy – hh:mm a').format(todo.dateTime)}",
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => openForm(index: index),
                                ),
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: priorityColor(todo.priority),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      // ===============================
      // FAB
      // ===============================
      floatingActionButton: FloatingActionButton(
        onPressed: () => openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
