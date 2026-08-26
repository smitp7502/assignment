import 'package:assignment/screens/edit_update_task_screen.dart';
import 'package:flutter/material.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Task Manager")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemBuilder: (ctx, i) => Text("data"),
              itemCount: 10,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EditUpdateTaskScreen()),
          );
        },
        child: Row(children: [Icon(Icons.add), Text("Add Task")]),
      ),
    );
  }
}
