import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskly/core/widgets/button_widget.dart';
import 'package:taskly/core/widgets/text_field_widget.dart';
import 'package:taskly/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:taskly/features/auth/presentation/blocs/auth_state.dart';
import 'package:taskly/features/tasks/domain/entities/category_entity.dart';
import 'package:taskly/features/tasks/presentation/blocs/task_bloc.dart';
import 'package:taskly/features/tasks/presentation/blocs/task_event.dart';
import 'package:taskly/features/tasks/presentation/blocs/task_state.dart';
import 'package:uuid/uuid.dart';
import 'package:taskly/features/tasks/presentation/view/components/category_list_widget.dart';

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
    return BlocListener<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state is TaskError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        } else if (state is TaskLoaded && state.operationCompleted != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.operationCompleted == 'category_created'
                    ? 'Category created'
                    : state.operationCompleted == 'category_updated'
                    ? 'Category updated'
                    : 'Category deleted',
              ),
            ),
          );
          _nameController.clear();
          _editingCategoryId = null;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Categories'),
          backgroundColor: Colors.orange,
          leading: IconButton(
            onPressed: () {
              if (GoRouter.of(context).canPop()) {
                GoRouter.of(context).pop();
              } else {
                GoRouter.of(context).go('/');
              }
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFieldWidget(
                        controller: _nameController,
                        hintText: 'Category Name',
                        validator: (value) =>
                            value!.isEmpty ? 'Name is required' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ButtonWidget(
                      text: _editingCategoryId == null ? 'Add' : 'Update',
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
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: CategoryListWidget(
                  editingCategoryId: _editingCategoryId,
                  onEdit: (id) => setState(() => _editingCategoryId = id),
                  nameController: _nameController,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
