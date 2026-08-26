import 'package:assignment/provider/task_provider.dart';
import 'package:assignment/screens/edit_update_task_screen.dart';
import 'package:assignment/widget/task_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<TaskProvider>().fetchTasks());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Task Manager'), centerTitle: true),
      body: _buildBody(provider),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditUpdateTaskScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  Widget _buildBody(TaskProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return _buildErrorState(provider.error!);
    }
    if (provider.tasks.isEmpty) {
      return _buildEmptyState();
    }
    return _buildTaskList(provider);
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            const Text(
              'Something went wrong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<TaskProvider>().fetchTasks();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.task_alt, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'No tasks found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4),
          Text(
            'Create a new task to get started.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(TaskProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: provider.tasks.length,
      itemBuilder: (context, index) {
        final task = provider.tasks[index];

        return TaskCard(
          task: task,
          onEdit: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditUpdateTaskScreen(task: task),
              ),
            );
          },
          onDelete: () {
            context.read<TaskProvider>().deleteTask(task.id);
          },
          onToggle: () {
            context.read<TaskProvider>().updateTask(
              task.id,
              task.title,
              !task.isCompleted,
              description: task.description,
            );
          },
        );
      },
    );
  }
}
