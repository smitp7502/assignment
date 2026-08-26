import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  int _selectedTab = 0;

  List<TaskModel> get tasks => [..._tasks];
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  int get selectedTab => _selectedTab;

  List<TaskModel> get filteredTasks {
    List<TaskModel> result = [..._tasks];
    switch (_selectedTab) {
      case 1:
        result = result.where((task) => task.isCompleted).toList();
        break;

      case 2:
        result = result.where((task) => !task.isCompleted).toList();
        break;

      default:
        break;
    }

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();

      result = result.where((task) {
        final title = task.title.toLowerCase();
        final description = task.description?.toLowerCase() ?? '';
        return title.contains(query) || description.contains(query);
      }).toList();
    }

    return result;
  }

  Future<void> refreshTasks() async {
    _error = null;

    try {
      final tasks = await _taskService.getTasks();
      _tasks = tasks;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void searchTasks(String query) {
    _searchQuery = query;

    notifyListeners();
  }

  void changeTab(int index) {
    _selectedTab = index;

    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';

    notifyListeners();
  }

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
      _tasks.insert(0, createdTask);
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
