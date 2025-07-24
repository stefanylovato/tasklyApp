import 'dart:io';

import '../entities/task_entity.dart';
import '../entities/category_entity.dart';

abstract class TaskRepository {
  Future<void> createTask(Task task);
  Future<List<Task>> getTasks(String userId);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String taskId, String userId);
  Future<void> createCategory(Category category);
  Future<List<Category>> getCategories(String userId);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String categoryId, String userId);
  Future<List<String>> uploadMedia(
    String taskId,
    String userId,
    List<File> files,
  );
}
