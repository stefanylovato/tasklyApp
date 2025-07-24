import 'dart:io';

import 'package:taskly/features/tasks/domain/entities/task_entity.dart';
import 'package:taskly/features/tasks/domain/entities/category_entity.dart';

abstract class ICreateTask {
  Future<void> call(Task task);
}

abstract class IGetTasks {
  Future<List<Task>> call(String userId);
}

abstract class IUpdateTask {
  Future<void> call(Task task);
}

abstract class IDeleteTask {
  Future<void> call(String taskId, String userId);
}

abstract class ICreateCategory {
  Future<void> call(Category category);
}

abstract class IGetCategories {
  Future<List<Category>> call(String userId);
}

abstract class IUpdateCategory {
  Future<void> call(Category category);
}

abstract class IDeleteCategory {
  Future<void> call(String categoryId, String userId);
}

abstract class IUploadMedia {
  Future<List<String>> call(String taskId, String userId, List<File> files);
}
