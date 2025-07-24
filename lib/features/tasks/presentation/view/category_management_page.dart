import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskly/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:taskly/features/auth/presentation/blocs/auth_state.dart';
import 'package:taskly/features/tasks/domain/entities/category_entity.dart';
import 'package:taskly/features/tasks/presentation/blocs/task_bloc.dart';
import 'package:taskly/features/tasks/presentation/blocs/task_event.dart';
import 'package:taskly/features/tasks/presentation/blocs/task_state.dart';
import 'package:uuid/uuid.dart';

class CategoryManagementPage extends StatefulWidget {
  const CategoryManagementPage({super.key});

  @override
  State<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _editingCategoryId;

  @override
  void initState() {
    super.initState();
    final userId =
        (context.read<AuthBloc>().state as AuthAuthenticated?)?.user.uid;
    if (userId != null) {
      context.read<TaskBloc>().add(LoadCategoriesEvent(userId));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        backgroundColor: Colors.orange,
        leading: IconButton(
          onPressed: () {
            context.go('/');
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // form for creating/editing category
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Category Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Name is required' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final userId =
                            (context.read<AuthBloc>().state
                                    as AuthAuthenticated)
                                .user
                                .uid;
                        final category = Category(
                          id: _editingCategoryId ?? const Uuid().v4(),
                          userId: userId,
                          name: _nameController.text,
                        );
                        context.read<TaskBloc>().add(
                          _editingCategoryId == null
                              ? CreateCategoryEvent(category)
                              : UpdateCategoryEvent(category),
                        );
                        _nameController.clear();
                        _editingCategoryId = null;
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(_editingCategoryId == null ? 'Add' : 'Update'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Category list
            Expanded(
              child: BlocBuilder<TaskBloc, TaskState>(
                builder: (context, state) {
                  if (state is TaskLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is TaskLoaded) {
                    final categories = state.categories;
                    if (categories.isEmpty) {
                      return const Center(child: Text('No categories found'));
                    }
                    return ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return ListTile(
                          title: Text(category.name),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _nameController.text = category.name;
                                  _editingCategoryId = category.id;
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  context.read<TaskBloc>().add(
                                    DeleteCategoryEvent(
                                      category.id,
                                      category.userId,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else if (state is TaskError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  return const Center(child: Text('No categories found'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
