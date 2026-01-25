import 'package:flutter/material.dart';
import 'package:to_do_application/models/todo_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Todo> todos = [];

  final TextEditingController titleController = TextEditingController();
  final TextEditingController placeController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  Priority selectedPriority = Priority.medium;

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  Future<void> pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() => selectedTime = time);
    }
  }

  void addTodo() {
    if (titleController.text.isEmpty ||
        placeController.text.isEmpty ||
        selectedDate == null ||
        selectedTime == null)
      return;

    setState(() {
      todos.add(
        Todo(
          title: titleController.text,
          place: placeController.text,
          date: selectedDate!,
          time: selectedTime!,
          priority: selectedPriority,
        ),
      );

      titleController.clear();
      placeController.clear();
      selectedDate = null;
      selectedTime = null;
      selectedPriority = Priority.medium;
    });
  }

  void toggleTodo(int index) {
    setState(() {
      todos[index].isDone = !todos[index].isDone;
    });
  }

  void deleteTodo(int index) {
    setState(() {
      todos.removeAt(index);
    });
  }

  void confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              deleteTodo(index);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Color priorityColor(Priority priority) {
    switch (priority) {
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 157, 218, 246),
        title: const Text(
          'To-Do Application',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: placeController,
                  decoration: const InputDecoration(
                    labelText: 'Place',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),

                DropdownButtonFormField<Priority>(
                  value: selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: Priority.low, child: Text('Low')),
                    DropdownMenuItem(
                      value: Priority.medium,
                      child: Text('Medium'),
                    ),
                    DropdownMenuItem(value: Priority.high, child: Text('High')),
                  ],
                  onChanged: (value) {
                    setState(() => selectedPriority = value!);
                  },
                ),

                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: pickDate,
                      child: Text(
                        selectedDate == null
                            ? 'Pick Date'
                            : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: pickTime,
                      child: Text(
                        selectedTime == null
                            ? 'Pick Time'
                            : selectedTime!.format(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: addTodo,
                  child: const Text('Add Task'),
                ),
              ],
            ),
          ),

          Expanded(
            child: todos.isEmpty
                ? const Center(child: Text('No tasks yet'))
                : ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          leading: Checkbox(
                            value: todo.isDone,
                            onChanged: (_) => toggleTodo(index),
                          ),
                          title: Text(
                            todo.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: todo.isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(todo.place),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 6,
                                children: [
                                  Chip(
                                    label: Text(
                                      '${todo.date.day}/${todo.date.month}/${todo.date.year}',
                                    ),
                                  ),
                                  Chip(label: Text(todo.time.format(context))),
                                  Chip(
                                    label: Text(
                                      todo.priority.name.toUpperCase(),
                                    ),
                                    backgroundColor: priorityColor(
                                      todo.priority,
                                    ).withOpacity(0.2),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => confirmDelete(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
