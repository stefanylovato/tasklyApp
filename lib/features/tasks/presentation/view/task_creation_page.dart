import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskly/core/widgets/button_widget.dart';
import 'package:taskly/core/widgets/text_field_widget.dart';
import 'package:taskly/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:taskly/features/auth/presentation/blocs/auth_state.dart';
import 'package:taskly/features/tasks/domain/entities/task_entity.dart';
import 'package:taskly/features/tasks/domain/entities/category_entity.dart';
import 'package:taskly/features/tasks/presentation/blocs/task_bloc.dart';
import 'package:taskly/features/tasks/presentation/blocs/task_event.dart';
import 'package:taskly/features/tasks/presentation/blocs/task_state.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:taskly/features/tasks/presentation/view/components/media_picker_widget.dart';

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

  Future<void> _pickDueDate({required VoidCallback onSuccess}) async {
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
                  TextFieldWidget(
                    controller: _titleController,
                    hintText: 'Title',
                    validator: (value) =>
                        value!.isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFieldWidget(
                    controller: _descriptionController,
                    hintText: 'Description',
                  ),
                  const SizedBox(height: 16),
                  TextFieldWidget(
                    controller: _dueDateController,
                    hintText: 'Due Date (YYYY-MM-DD)',
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
                    decoration: InputDecoration(
                      labelText: 'Status',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: TaskStatus.values
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status.toString().split('.').last),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _status = value!),
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
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.white,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.white,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.white,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onChanged: null,
                            ),
                            const SizedBox(height: 16),
                            const Center(child: CircularProgressIndicator()),
                          ],
                        );
                      } else if (state is TaskError) {
                        return Text('Error: ${state.message}');
                      }
                      return DropdownButtonFormField<Category>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                        onChanged: (value) =>
                            setState(() => _selectedCategory = value),
                        validator: (value) =>
                            value == null ? 'Category is required' : null,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  MediaPickerWidget(
                    mediaFiles: _mediaFiles,
                    onAdd: (file) => setState(() => _mediaFiles.add(file)),
                    onRemove: (index) =>
                        setState(() => _mediaFiles.removeAt(index)),
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<TaskBloc, TaskState>(
                    buildWhen: (previous, current) =>
                        previous is TaskLoading != current is TaskLoading,
                    builder: (context, state) {
                      return ButtonWidget(
                        text: widget.taskId == null ? 'Create' : 'Update',
                        isLoading: _isSaving || state is TaskLoading,
                        onPressed: () => _saveTask(
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
