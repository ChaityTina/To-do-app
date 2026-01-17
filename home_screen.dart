import 'package:flutter/material.dart';
import 'package:to_do_application/models/todo_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Todo> todos = [];
  final TextEditingController controller = TextEditingController();

  // Add a new todo
  void addTodo() {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      todos.add(Todo(title: text));
      controller.clear();
      FocusScope.of(context).unfocus(); // dismiss keyboard
    });
  }

  // Toggle the completion status
  void toggleTodo(int index) {
    setState(() {
      todos[index].isDone = !todos[index].isDone;
    });
  }

  // Delete a todo
  void deleteTodo(int index) {
    setState(() {
      todos.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 150, 214, 243),
        title: Column(
          children: const [
            Text(
              'To-Do Application',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 25),
            ),
            SizedBox(height: 4),
            Text(
              'Organize your tasks efficiently!',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Color.fromARGB(255, 249, 81, 81),
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 2,
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter task',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => addTodo(), // press enter to add
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: addTodo, child: const Text('Add')),
              ],
            ),
          ),

          // List of todos
          Expanded(
            child: todos.isEmpty
                ? const Center(
                    child: Text(
                      'No tasks yet!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      return ListTile(
                        leading: Checkbox(
                          value: todo.isDone,
                          onChanged: (_) => toggleTodo(index),
                        ),
                        title: Text(
                          todo.title,
                          style: TextStyle(
                            decoration: todo.isDone
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteTodo(index),
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
