import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/todo.dart';

class TodoService {
  final http.Client _client;

  TodoService({http.Client? client}) : _client = client ?? http.Client();

  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<Todo>> fetchTodos() async {
    final response = await _client.get(Uri.parse('$baseUrl/todos'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load todos: ${response.statusCode}');
    }

    final List<dynamic> decoded = jsonDecode(response.body);
    return decoded.map((item) => Todo.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Todo> createTodo({
    required int userId,
    required String title,
    bool completed = false,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/todos'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'userId': userId,
        'title': title,
        'completed': completed,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create todo: ${response.statusCode}');
    }

    return Todo.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
