import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';

class TaskService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<TaskModel>> getTasks() async {
    final response = await http.get(Uri.parse('$baseUrl/posts'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load tasks');
    }

    final List data = jsonDecode(response.body);

    return data.map((json) => TaskModel.fromJson(json)).toList();
  }

  Future<TaskModel> createTask(TaskModel task) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create task');
    }

    return TaskModel.fromJson(jsonDecode(response.body));
  }

  Future<TaskModel> updateTask(TaskModel task) async {
    final response = await http.put(
      Uri.parse('$baseUrl/posts/${task.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update task');
    }

    return TaskModel.fromJson(jsonDecode(response.body));
  }

  Future<void> deleteTask(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/posts/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete task');
    }
  }
}
