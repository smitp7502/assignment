import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<TaskModel> get tasks => [..._tasks];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _taskService.getTasks();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(
    String title,
    bool isCompleted, {
    String? description,
  }) async {
    try {
      final task = TaskModel(
        title: title,
        description: description,
        userId: 1,
        id: 0,
        isCompleted: isCompleted,
      );

      final createdTask = await _taskService.createTask(task);
      _tasks.add(createdTask);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateTask(
    int id,
    String title,
    bool isCompleted, {
    String? description,
  }) async {
    try {
      final index = _tasks.indexWhere((task) => task.id == id);

      if (index == -1) return;
      final updatedTask = _tasks[index].copyWith(
        title: title,
        description: description,
        isCompleted: isCompleted,
      );

      final responseTask = await _taskService.updateTask(updatedTask);
      _tasks[index] = responseTask;

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _taskService.deleteTask(id);

      _tasks.removeWhere((task) => task.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
