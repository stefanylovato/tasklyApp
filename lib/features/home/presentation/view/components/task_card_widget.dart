import 'package:flutter/material.dart';
import 'package:taskly/features/tasks/domain/entities/task_entity.dart';
import 'package:taskly/features/tasks/domain/entities/category_entity.dart';

class TaskCardWidget extends StatefulWidget {
  final Task task;
  final VoidCallback onDelete;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController dueDateController;
  final Function(TaskStatus) onStatusChanged;
  final Function(Category?) onCategoryChanged;

  const TaskCardWidget({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onSave,
    required this.onCancel,
    required this.titleController,
    required this.descriptionController,
    required this.dueDateController,
    required this.onStatusChanged,
    required this.onCategoryChanged,
  });

  @override
  State<TaskCardWidget> createState() => _TaskCardWidgetState();
}

class _TaskCardWidgetState extends State<TaskCardWidget> {
  late TaskStatus _status;
  late Category? _category;

  @override
  void initState() {
    super.initState();
    _status = widget.task.status;
    _category = widget.task.categoryName.isNotEmpty
        ? Category(
            id: widget.task.categoryId,
            userId: widget.task.userId,
            name: widget.task.categoryName,
          )
        : null;
    widget.titleController.text = widget.task.title;
    widget.descriptionController.text = widget.task.description;
    widget.dueDateController.text = widget.task.dueDate
        .toIso8601String()
        .split('T')
        .first;
  }

  Future<void> _pickDueDate(VoidCallback onSuccess) async {
    final initialDate = widget.dueDateController.text.isNotEmpty
        ? DateTime.tryParse(widget.dueDateController.text) ?? DateTime.now()
        : DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        widget.dueDateController.text = pickedDate.toString().substring(0, 10);
      });
      onSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          widget.task.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Category: ${widget.task.categoryName}\nStatus: ${widget.task.status.toString().split('.').last}',
          style: const TextStyle(fontSize: 12),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: widget.titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: widget.descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: widget.dueDateController,
                  decoration: const InputDecoration(
                    labelText: 'Due Date (YYYY-MM-DD)',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _pickDueDate(() {}),
                  validator: (value) {
                    if (value!.isEmpty) return 'Due date is required';
                    try {
                      DateTime.parse(value);
                      return null;
                    } catch (e) {
                      return 'Invalid date format';
                    }
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<TaskStatus>(
                  value: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: TaskStatus.values
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.toString().split('.').last),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _status = value);
                      widget.onStatusChanged(value);
                    }
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<Category>(
                  value: _category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    if (_category != null)
                      DropdownMenuItem(
                        value: _category,
                        child: Text(_category!.name),
                      ),
                  ],
                  onChanged: (value) {
                    setState(() => _category = value);
                    widget.onCategoryChanged(value);
                  },
                  validator: (value) =>
                      value == null ? 'Category is required' : null,
                ),
                const SizedBox(height: 8),
                if (widget.task.mediaUrls.isNotEmpty) ...[
                  const Text(
                    'Media:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.task.mediaUrls
                        .map(
                          (url) => Image.network(
                            url,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: widget.onDelete,
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: widget.onCancel,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.orange,
                          ),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: widget.onSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
