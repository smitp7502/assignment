import 'package:flutter/material.dart';

import '../models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggle;

  const TaskCard({
    super.key,
    required this.task,
    this.onEdit,
    this.onDelete,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: task.isCompleted,
              onChanged: (_) => onToggle?.call(),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),

                  if (task.description != null &&
                      task.description!.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      task.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: task.isCompleted
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      task.isCompleted ? 'Completed' : 'Pending',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: task.isCompleted ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onEdit?.call();
                    break;
                  case 'delete':
                    onDelete?.call();
                    break;
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
