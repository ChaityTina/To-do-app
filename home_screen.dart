import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/todo_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final box = Hive.box('todos');

  List<Todo> todos = [];
  List<Todo> filtered = [];

  final titleC = TextEditingController();
  final placeC = TextEditingController();

  Priority priority = Priority.medium;
  DateTime? dateTime;

  String search = "";

  @override
  void initState() {
    super.initState();
    loadTodos();
  }

  void loadTodos() {
    final data = box.get('tasks', defaultValue: []) as List;

    todos = data
        .map((e) => Todo.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    applyFilter();
  }

  void saveTodos() {
    box.put('tasks', todos.map((e) => e.toMap()).toList());
  }

  void applyFilter() {
    filtered = todos
        .where((t) => t.title.toLowerCase().contains(search.toLowerCase()))
        .toList();

    filtered.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    setState(() {});
  }

  void addOrEdit({int? index}) {
    if (titleC.text.isEmpty || placeC.text.isEmpty || dateTime == null) return;

    final task = Todo(
      title: titleC.text,
      place: placeC.text,
      dateTime: dateTime!,
      priority: priority,
    );

    setState(() {
      index == null ? todos.add(task) : todos[index] = task;
      saveTodos();
      applyFilter();
    });

    Navigator.pop(context);
  }

  Color priorityColor(Priority p) {
    switch (p) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  void openForm({int? index}) {
    if (index != null) {
      final t = filtered[index];
      titleC.text = t.title;
      placeC.text = t.place;
      priority = t.priority;
      dateTime = t.dateTime;
    } else {
      titleC.clear();
      placeC.clear();
      dateTime = null;
      priority = Priority.medium;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          children: [
            TextField(
              controller: titleC,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: placeC,
              decoration: const InputDecoration(labelText: "Place"),
            ),

            DropdownButtonFormField(
              value: priority,
              items: Priority.values
                  .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                  .toList(),
              onChanged: (v) => priority = v!,
            ),

            ElevatedButton(
              child: const Text("Pick Date & Time"),
              onPressed: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );

                final t = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                if (d != null && t != null) {
                  dateTime = DateTime(d.year, d.month, d.day, t.hour, t.minute);
                }
              },
            ),

            ElevatedButton(
              onPressed: () => addOrEdit(index: index),
              child: Text(index == null ? "Add Task" : "Update Task"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int done = todos.where((e) => e.isDone).length;
    double progress = todos.isEmpty ? 0 : done / todos.length;

    return Scaffold(
      appBar: AppBar(title: const Text("Task Manager")),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search Task",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) {
                search = v;
                applyFilter();
              },
            ),
          ),

          LinearProgressIndicator(value: progress),

          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text("No Tasks"))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final t = filtered[i];

                      return Card(
                        child: ListTile(
                          leading: Checkbox(
                            value: t.isDone,
                            onChanged: (_) {
                              setState(() {
                                t.isDone = !t.isDone;
                                saveTodos();
                              });
                            },
                          ),

                          title: Text(t.title),

                          subtitle: Text(
                            "${t.place}\n${DateFormat('dd MMM yyyy – hh:mm a').format(t.dateTime)}",
                          ),

                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => openForm(index: i),
                              ),

                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    todos.remove(t);
                                    saveTodos();
                                    applyFilter();
                                  });
                                },
                              ),

                              CircleAvatar(
                                radius: 6,
                                backgroundColor: priorityColor(t.priority),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
