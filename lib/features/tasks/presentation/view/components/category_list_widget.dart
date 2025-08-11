import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskly/features/tasks/presentation/blocs/task_bloc.dart';
import 'package:taskly/features/tasks/presentation/blocs/task_event.dart';
import 'package:taskly/features/tasks/presentation/blocs/task_state.dart';

class CategoryListWidget extends StatelessWidget {
  final String? editingCategoryId;
  final void Function(String) onEdit;
  final TextEditingController nameController;

  const CategoryListWidget({
    super.key,
    this.editingCategoryId,
    required this.onEdit,
    required this.nameController,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
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
                        nameController.text = category.name;
                        onEdit(category.id);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        context.read<TaskBloc>().add(
                          DeleteCategoryEvent(category.id, category.userId),
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
    );
  }
}
