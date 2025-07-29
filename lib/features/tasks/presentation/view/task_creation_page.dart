import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taskly/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:taskly/features/auth/presentation/blocs/auth_state.dart';
import 'package:taskly/features/tasks/domain/entities/task_entity.dart';
import 'package:taskly/features/tasks/domain/entities/category_entity.dart';
import 'package:taskly/features/tasks/presentation/blocs/task_bloc.dart';
import 'package:taskly/features/tasks/presentation/blocs/task_event.dart';
import 'package:taskly/features/tasks/presentation/blocs/task_state.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

class TaskCreationPage extends StatefulWidget {
  final String? taskId;

  const TaskCreationPage({super.key, this.taskId});

  @override
  State<TaskCreationPage> createState() => _TaskCreationPageState();
}

class _TaskCreationPageState extends State<TaskCreationPage>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateController = TextEditingController();
  TaskStatus _status = TaskStatus.toDo;
  Category? _selectedCategory;
  final List<File> _mediaFiles = [];
  bool _isSaving = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final userId = authState.user.uid;
      context.read<TaskBloc>().add(LoadCategoriesEvent(userId));
      if (widget.taskId != null) {
        context.read<TaskBloc>().add(LoadTaskByIdEvent(widget.taskId!, userId));
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia({
    required VoidCallback onSuccess,
    required void Function(String message) onError,
  }) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        if (await file.exists()) {
          setState(() {
            _mediaFiles.add(file);
          });
          onSuccess();
        } else {
          onError('Selected file is invalid');
        }
      }
    } catch (e) {
      onError('Error picking media: $e');
    }
  }

  Future<void> _pickDueDate({
    required VoidCallback onSuccess,
  }) async {
    final initialDate = _dueDateController.text.isNotEmpty
        ? DateTime.tryParse(_dueDateController.text) ?? DateTime.now()
        : DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _dueDateController.text = pickedDate.toString().substring(0, 10);
      });
      onSuccess();
    }
  }

  Future<void> _saveTask({
    required BuildContext context,
    required VoidCallback onSuccess,
    required void Function(String message) onError,
  }) async {
    if (_isSaving) return;
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        setState(() => _isSaving = false);
        onError('User not authenticated');
        return;
      }
      final userId = authState.user.uid;
      final taskId = widget.taskId ?? const Uuid().v4();
      try {
        List<String> mediaUrls = [];
        if (_mediaFiles.isNotEmpty) {
          mediaUrls = await context.read<TaskBloc>().uploadMedia(
            taskId,
            userId,
            _mediaFiles,
          );
        }
        if (_selectedCategory == null) {
          setState(() => _isSaving = false);
          onError('Please select a category');
          return;
        }
        final task = Task(
          id: taskId,
          userId: userId,
          title: _titleController.text,
          description: _descriptionController.text,
          dueDate: DateTime.parse(_dueDateController.text),
          categoryId: _selectedCategory!.id,
          categoryName: _selectedCategory!.name,
          status: _status,
          mediaUrls: mediaUrls,
        );
        context.read<TaskBloc>().add(
          widget.taskId == null ? CreateTaskEvent(task) : UpdateTaskEvent(task),
        );
        onSuccess();
      } catch (e) {
        setState(() => _isSaving = false);
        onError('Error saving task: $e');
      }
    } else {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state is TaskError) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        } else if (state is TaskLoaded &&
            widget.taskId != null &&
            state.selectedTask != null) {
          final task = state.selectedTask!;
          _titleController.text = task.title;
          _descriptionController.text = task.description;
          _dueDateController.text = task.dueDate.toString().substring(0, 10);
          _status = task.status;
          _selectedCategory = state.categories.firstWhere(
            (c) => c.id == task.categoryId,
            orElse: () => Category(
              id: task.categoryId,
              userId: task.userId,
              name: task.categoryName,
            ),
          );
          setState(() {});
        } else if (state is TaskLoaded && widget.taskId == null) {
          if (state.categories.isNotEmpty && _selectedCategory == null) {
            _selectedCategory = state.categories.first;
            setState(() {});
          }
          if (state.mediaUrls.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Uploaded ${state.mediaUrls.length} media file(s)',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else if (state is TaskLoaded && state.operationCompleted != null) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.operationCompleted == 'created'
                    ? 'Task created'
                    : 'Task updated',
              ),
            ),
          );
          if (GoRouter.of(context).canPop()) {
            GoRouter.of(context).pop();
          } else {
            GoRouter.of(context).go('/');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.taskId == null ? 'Create Task' : 'Edit Task'),
          backgroundColor: Colors.orange,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (GoRouter.of(context).canPop()) {
                GoRouter.of(context).pop();
              } else {
                GoRouter.of(context).go('/');
              }
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dueDateController,
                    decoration: const InputDecoration(
                      labelText: 'Due Date (YYYY-MM-DD)',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () => _pickDueDate(onSuccess: () {}),
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
                  const SizedBox(height: 16),
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
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<TaskBloc, TaskState>(
                    buildWhen: (previous, current) =>
                        previous is TaskLoaded &&
                        current is TaskLoaded &&
                        previous.categories != current.categories,
                    builder: (context, state) {
                      List<Category> categories = [];
                      if (state is TaskLoaded) {
                        categories = state.categories;
                        if (categories.isNotEmpty &&
                            _selectedCategory == null) {
                          _selectedCategory = categories.first;
                        }
                      } else if (state is TaskLoading) {
                        return Column(
                          children: [
                            DropdownButtonFormField(
                              items: [],
                              decoration: InputDecoration(
                                labelText: 'Category',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: null,
                            ),
                            SizedBox(height: 16),
                            Center(child: CircularProgressIndicator()),
                          ],
                        );
                      } else if (state is TaskError) {
                        return Text('Error: ${state.message}');
                      }
                      return DropdownButtonFormField<Category>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: categories.isEmpty
                            ? [
                                DropdownMenuItem(
                                  value: Category(
                                    id: '',
                                    userId: '',
                                    name: 'No Category',
                                  ),
                                  child: const Text('No Category'),
                                ),
                              ]
                            : categories
                                  .map(
                                    (category) => DropdownMenuItem(
                                      value: category,
                                      child: Text(category.name),
                                    ),
                                  )
                                  .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedCategory = value);
                          }
                        },
                        validator: (value) =>
                            value == null ? 'Category is required' : null,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => _pickMedia(
                      onSuccess: () {},
                      onError: (message) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(message)),
                          );
                        }
                      },
                    ),
                    child: const Text('Pick Image from Gallery'),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _mediaFiles
                        .asMap()
                        .entries
                        .map(
                          (entry) => Stack(
                            children: [
                              Image.file(
                                entry.value,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _mediaFiles.removeAt(entry.key);
                                    });
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<TaskBloc, TaskState>(
                    buildWhen: (previous, current) =>
                        previous is TaskLoading != current is TaskLoading,
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: _isSaving || state is TaskLoading
                            ? null
                            : () => _saveTask(
                                context: context,
                                onSuccess: () {
                                  if (mounted) {
                                    if (GoRouter.of(context).canPop()) {
                                      GoRouter.of(context).pop();
                                    } else {
                                      GoRouter.of(context).go('/');
                                    }
                                  }
                                },
                                onError: (message) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(message)),
                                    );
                                  }
                                },
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 32,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(widget.taskId == null ? 'Create' : 'Update'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
