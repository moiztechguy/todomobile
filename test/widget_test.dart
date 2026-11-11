import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/models/todo.dart';
import 'package:flutter_application_1/services/todo_service.dart';

class MockTodoService extends TodoService {
  @override
  Future<List<Todo>> fetchTodos() async {
    return const [
      Todo(userId: 1, id: 1, title: 'Write lesson notes', completed: true),
      Todo(userId: 1, id: 2, title: 'Practice Flutter', completed: false),
    ];
  }

  @override
  Future<Todo> createTodo({
    required int userId,
    required String title,
    bool completed = false,
  }) async {
    return Todo(userId: userId, id: 99, title: title, completed: completed);
  }
}

void main() {
  testWidgets('todo screen shows completed count in app bar and todo items', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => TodoController(service: MockTodoService())..loadTodos(),
        child: const MaterialApp(home: TodoListScreen()),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.text('Done: 1'), findsOneWidget);
    expect(find.text('Write lesson notes'), findsOneWidget);
    expect(find.text('Practice Flutter'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
  });
}
