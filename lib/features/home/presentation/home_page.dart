import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taskly/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:taskly/features/auth/presentation/blocs/auth_event.dart';
import 'package:taskly/features/auth/presentation/blocs/auth_state.dart';
import 'package:taskly/features/tasks/domain/entities/task_entity.dart';
import 'package:taskly/features/tasks/domain/entities/category_entity.dart';
import 'package:taskly/features/tasks/presentation/blocs/task_bloc.dart';
import 'package:taskly/features/tasks/presentation/blocs/task_event.dart';
import 'package:taskly/features/tasks/presentation/blocs/task_state.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  final Map<String, GlobalKey<FormState>> _formKeys = {};
  final Map<String, TextEditingController> _titleControllers = {};
  final Map<String, TextEditingController> _descriptionControllers = {};
  final Map<String, TextEditingController> _dueDateControllers = {};
  final Map<String, TaskStatus> _statusMap = {};
  final Map<String, Category?> _categoryMap = {};

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadTasks();
  }

  void _loadTasks() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<TaskBloc>().add(LoadTasksEvent(authState.user.uid));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _titleControllers.forEach((_, controller) => controller.dispose());
    _descriptionControllers.forEach((_, controller) => controller.dispose());
    _dueDateControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context.read<TaskBloc>().add(
          FilterTasksEvent(value, authState.user.uid),
        );
      }
    });
  }

  Future<void> _pickDueDate(String taskId, VoidCallback onSuccess) async {
    final initialDate = _dueDateControllers[taskId]!.text.isNotEmpty
        ? DateTime.tryParse(_dueDateControllers[taskId]!.text) ?? DateTime.now()
        : DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _dueDateControllers[taskId]!.text = pickedDate.toString().substring(
          0,
          10,
        );
      });
      onSuccess();
    }
  }

  void _saveTask(Task task) {
    final formKey = _formKeys[task.id];
    if (formKey != null && formKey.currentState!.validate()) {
      final updatedTask = Task(
        id: task.id,
        userId: task.userId,
        title: _titleControllers[task.id]!.text,
        description: _descriptionControllers[task.id]!.text,
        dueDate: DateTime.parse(_dueDateControllers[task.id]!.text),
        categoryId: _categoryMap[task.id]!.id,
        categoryName: _categoryMap[task.id]!.name,
        status: _statusMap[task.id]!,
        mediaUrls: task.mediaUrls,
      );
      context.read<TaskBloc>().add(UpdateTaskEvent(updatedTask));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/login');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      child: BlocListener<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          } else if (state is TaskLoaded && state.operationCompleted != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.operationCompleted == 'created'
                      ? 'Task created'
                      : state.operationCompleted == 'updated'
                      ? 'Task updated'
                      : state.operationCompleted == 'deleted'
                      ? 'Task deleted'
                      : state.operationCompleted == 'category_created'
                      ? 'Category created'
                      : state.operationCompleted == 'category_updated'
                      ? 'Category updated'
                      : 'Category deleted',
                ),
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.grey[300],
          appBar: AppBar(
            title: Text(
              'Taskly',
              style: GoogleFonts.mulish(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.left,
            ),
            backgroundColor: Colors.orange,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () {
                  context.read<AuthBloc>().add(AuthLogoutEvent());
                },
                tooltip: 'Logout',
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.orange,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.category),
                label: 'Categories',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add),
                label: 'Add Task',
              ),
            ],
            onTap: (index) {
              if (index == 0) {
                context.go('/category-management');
              } else {
                context.go('/task-creation');
              }
            },
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search tasks...',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<TaskBloc, TaskState>(
                    buildWhen: (previous, current) =>
                        (current is TaskLoading && previous is! TaskLoading) ||
                        (current is TaskLoaded &&
                            (previous is! TaskLoaded ||
                                previous.tasks != current.tasks ||
                                previous.filteredTasks !=
                                    current.filteredTasks)) ||
                        (current is TaskError && previous is! TaskError),
                    builder: (context, state) {
                      if (state is TaskLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is TaskLoaded) {
                        final tasks = state.filteredTasks;
                        final categories = state.categories;
                        if (tasks.isEmpty) {
                          return const Center(child: Text('No tasks found'));
                        }
                        return ListView.builder(
                          physics: AlwaysScrollableScrollPhysics(),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            if (!_formKeys.containsKey(task.id)) {
                              _formKeys[task.id] = GlobalKey<FormState>();
                              _titleControllers[task.id] =
                                  TextEditingController(text: task.title);
                              _descriptionControllers[task.id] =
                                  TextEditingController(text: task.description);
                              _dueDateControllers[task.id] =
                                  TextEditingController(
                                    text: task.dueDate
                                        .toIso8601String()
                                        .split('T')
                                        .first,
                                  );
                              _statusMap[task.id] = task.status;
                              _categoryMap[task.id] = categories.firstWhere(
                                (c) => c.id == task.categoryId,
                                orElse: () => Category(
                                  id: task.categoryId,
                                  userId: task.userId,
                                  name: task.categoryName,
                                ),
                              );
                            }
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 5.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ExpansionTile(
                                title: Text(
                                  task.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'Category: ${task.categoryName}\nStatus: ${task.status.toString().split('.').last}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Form(
                                      key: _formKeys[task.id],
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextFormField(
                                            controller:
                                                _titleControllers[task.id],
                                            decoration: const InputDecoration(
                                              labelText: 'Title',
                                              border: OutlineInputBorder(),
                                            ),
                                            validator: (value) => value!.isEmpty
                                                ? 'Title is required'
                                                : null,
                                          ),
                                          const SizedBox(height: 8),
                                          TextFormField(
                                            controller:
                                                _descriptionControllers[task
                                                    .id],
                                            decoration: const InputDecoration(
                                              labelText: 'Description',
                                              border: OutlineInputBorder(),
                                            ),
                                            maxLines: 3,
                                          ),
                                          const SizedBox(height: 8),
                                          TextFormField(
                                            controller:
                                                _dueDateControllers[task.id],
                                            decoration: const InputDecoration(
                                              labelText:
                                                  'Due Date (YYYY-MM-DD)',
                                              border: OutlineInputBorder(),
                                              suffixIcon: Icon(
                                                Icons.calendar_today,
                                              ),
                                            ),
                                            readOnly: true,
                                            onTap: () =>
                                                _pickDueDate(task.id, () {}),
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Due date is required';
                                              }
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
                                            value: _statusMap[task.id],
                                            decoration: const InputDecoration(
                                              labelText: 'Status',
                                              border: OutlineInputBorder(),
                                            ),
                                            items: TaskStatus.values
                                                .map(
                                                  (status) => DropdownMenuItem(
                                                    value: status,
                                                    child: Text(
                                                      status
                                                          .toString()
                                                          .split('.')
                                                          .last,
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                            onChanged: (value) {
                                              if (value != null) {
                                                setState(
                                                  () => _statusMap[task.id] =
                                                      value,
                                                );
                                              }
                                            },
                                          ),
                                          const SizedBox(height: 8),
                                          DropdownButtonFormField<Category>(
                                            value: _categoryMap[task.id],
                                            decoration: const InputDecoration(
                                              labelText: 'Category',
                                              border: OutlineInputBorder(),
                                            ),
                                            items: categories
                                                .map(
                                                  (category) =>
                                                      DropdownMenuItem(
                                                        value: category,
                                                        child: Text(
                                                          category.name,
                                                        ),
                                                      ),
                                                )
                                                .toList(),
                                            onChanged: (value) {
                                              if (value != null) {
                                                setState(
                                                  () => _categoryMap[task.id] =
                                                      value,
                                                );
                                              }
                                            },
                                            validator: (value) => value == null
                                                ? 'Category is required'
                                                : null,
                                          ),
                                          const SizedBox(height: 8),
                                          if (task.mediaUrls.isNotEmpty) ...[
                                            const Text(
                                              'Media:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children: task.mediaUrls
                                                  .map(
                                                    (url) => Image.network(
                                                      url,
                                                      width: 100,
                                                      height: 100,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) => const Icon(
                                                            Icons.broken_image,
                                                          ),
                                                    ),
                                                  )
                                                  .toList(),
                                            ),
                                            const SizedBox(height: 8),
                                          ],
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
                                                  context.read<TaskBloc>().add(
                                                    DeleteTaskEvent(
                                                      task.id,
                                                      task.userId,
                                                    ),
                                                  );
                                                },
                                              ),
                                              Row(
                                                children: [
                                                  TextButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        _titleControllers[task
                                                                    .id]!
                                                                .text =
                                                            task.title;
                                                        _descriptionControllers[task
                                                                    .id]!
                                                                .text =
                                                            task.description;
                                                        _dueDateControllers[task
                                                                .id]!
                                                            .text = task.dueDate
                                                            .toIso8601String()
                                                            .split('T')
                                                            .first;
                                                        _statusMap[task.id] =
                                                            task.status;
                                                        _categoryMap[task
                                                            .id] = categories
                                                            .firstWhere(
                                                              (c) =>
                                                                  c.id ==
                                                                  task.categoryId,
                                                              orElse: () => Category(
                                                                id: task
                                                                    .categoryId,
                                                                userId:
                                                                    task.userId,
                                                                name: task
                                                                    .categoryName,
                                                              ),
                                                            );
                                                      });
                                                    },
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          Colors.orange,
                                                    ),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  ElevatedButton(
                                                    onPressed: () =>
                                                        _saveTask(task),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.orange,
                                                      foregroundColor:
                                                          Colors.white,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
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
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      } else if (state is TaskError) {
                        return Center(child: Text('Error: ${state.message}'));
                      }
                      return const Center(child: Text('No tasks loaded'));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
