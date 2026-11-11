import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/todo.dart';
import 'services/todo_service.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TodoController(service: TodoService())..loadTodos(),
      child: MaterialApp(
        title: 'Todo Practice',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const TodoListScreen(),
      ),
    );
  }
}

class TodoController extends ChangeNotifier {
  TodoController({TodoService? service}) : _service = service ?? TodoService();

  final TodoService _service;
  List<Todo> _todos = <Todo>[];
  bool _isLoading = false;
  String? _errorMessage;

  List<Todo> get todos => _todos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get completedCount => _todos.where((todo) => todo.completed).length;

  Future<void> loadTodos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _todos = await _service.fetchTodos();
    } catch (error) {
      _errorMessage = 'Unable to load todos';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTodo({
    required int userId,
    required String title,
    bool completed = false,
  }) async {
    final todo = await _service.createTodo(
      userId: userId,
      title: title,
      completed: completed,
    );

    _todos.insert(0, todo);
    notifyListeners();
  }
}

class TodoListScreen extends StatelessWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final completedText = context.select<TodoController, String>(
      (controller) => 'Done: ${controller.completedCount}',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Practice'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                completedText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTodoDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Todo'),
      ),
      body: Consumer<TodoController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null) {
            return Center(
              child: Text(controller.errorMessage!),
            );
          }

          if (controller.todos.isEmpty) {
            return const Center(child: Text('No todos available'));
          }

          return ListView.separated(
            itemCount: controller.todos.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final todo = controller.todos[index];

              return ListTile(
                leading: Icon(
                  todo.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: todo.completed ? Colors.green : Colors.grey,
                ),
                title: Text(todo.title),
                subtitle: Text('User: ${todo.userId} • ID: ${todo.id}'),
                trailing: todo.completed
                    ? const Icon(Icons.done, color: Colors.green)
                    : const Icon(Icons.pending_outlined, color: Colors.orange),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showAddTodoDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final userIdController = TextEditingController(text: '1');
    bool completed = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Todo'),
              content: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: userIdController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'User ID'),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      value: completed,
                      title: const Text('Completed'),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (value) {
                        setState(() {
                          completed = value ?? false;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final userId = int.tryParse(userIdController.text.trim()) ?? 1;

                    if (title.isEmpty) {
                      return;
                    }

                    Navigator.pop(dialogContext);
                    await context.read<TodoController>().addTodo(
                      userId: userId,
                      title: title,
                      completed: completed,
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
