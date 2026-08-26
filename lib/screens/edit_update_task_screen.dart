import 'package:assignment/models/task_model.dart';
import 'package:assignment/provider/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditUpdateTaskScreen extends StatefulWidget {
  final TaskModel? task;
  const EditUpdateTaskScreen({super.key, this.task});
  bool get isEditMode => task != null;

  @override
  State<EditUpdateTaskScreen> createState() => _EditUpdateTaskScreenState();
}

class _EditUpdateTaskScreenState extends State<EditUpdateTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  bool _isCompleted = false;
  bool _isSubmitting = false;
  bool get isEditMode => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _isCompleted = widget.task?.isCompleted ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final provider = context.read<TaskProvider>();

    try {
      if (isEditMode) {
        await provider.updateTask(
          widget.task!.id,
          _titleController.text.trim(),
          _isCompleted,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        );
      } else {
        await provider.addTask(
          _titleController.text.trim(),
          _isCompleted,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditMode ? 'Failed to update task' : 'Failed to add task',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Update Task' : 'Add Task'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter task title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }

                if (value.trim().length < 3) {
                  return 'Title must be at least 3 characters';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter task description',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 16),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _isCompleted ? 'Completed' : 'Pending',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                _isCompleted
                    ? 'Mark this task as pending'
                    : 'Mark this task as completed',
              ),
              value: _isCompleted,
              onChanged: (value) {
                setState(() {
                  _isCompleted = value;
                });
              },
            ),

            const SizedBox(height: 24),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isEditMode ? 'Update Task' : 'Add Task'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
