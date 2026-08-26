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
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    Future.microtask(() {
      if (mounted) {
        context.read<TaskProvider>().fetchTasks();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Task Manager'), centerTitle: true),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildTabBar(),
          Expanded(child: _buildBody(provider)),
        ],
      ),
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          context.read<TaskProvider>().searchTasks(value);
        },
        decoration: InputDecoration(
          hintText: 'Search task...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    context.read<TaskProvider>().clearSearch();
                    setState(() {});
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final provider = context.watch<TaskProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildTab(
            title: 'All',
            index: 0,
            selectedIndex: provider.selectedTab,
          ),
          _buildTab(
            title: 'Completed',
            index: 1,
            selectedIndex: provider.selectedTab,
          ),
          _buildTab(
            title: 'Pending',
            index: 2,
            selectedIndex: provider.selectedTab,
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String title,
    required int index,
    required int selectedIndex,
  }) {
    final isSelected = index == selectedIndex;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ChoiceChip(
          label: SizedBox(
            width: double.infinity,
            child: Text(title, textAlign: TextAlign.center),
          ),
          selected: isSelected,
          onSelected: (_) {
            context.read<TaskProvider>().changeTab(index);
          },
        ),
      ),
    );
  }

  Widget _buildBody(TaskProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    Widget content;
    if (provider.error != null) {
      content = _buildErrorState(provider.error!);
    } else if (provider.filteredTasks.isEmpty) {
      content = _buildEmptyState();
    } else {
      content = _buildTaskList(provider);
    }

    return RefreshIndicator(
      onRefresh: () => context.read<TaskProvider>().refreshTasks(),
      child: content,
    );
  }

  Widget _buildErrorState(String error) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
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
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: const Center(
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
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(TaskProvider provider) {
    final tasks = provider.filteredTasks;
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];

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
