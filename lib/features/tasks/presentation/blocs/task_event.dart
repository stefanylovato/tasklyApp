import 'package:equatable/equatable.dart';
import 'package:taskly/features/tasks/domain/entities/category_entity.dart';
import 'package:taskly/features/tasks/domain/entities/task_entity.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object> get props => [];
}

class LoadTasksEvent extends TaskEvent {
  final String userId;

  const LoadTasksEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class LoadCategoriesEvent extends TaskEvent {
  final String userId;

  const LoadCategoriesEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class CreateTaskEvent extends TaskEvent {
  final Task task;

  const CreateTaskEvent(this.task);

  @override
  List<Object> get props => [task];
}

class UpdateTaskEvent extends TaskEvent {
  final Task task;

  const UpdateTaskEvent(this.task);

  @override
  List<Object> get props => [task];
}

class DeleteTaskEvent extends TaskEvent {
  final String taskId;
  final String userId;

  const DeleteTaskEvent(this.taskId, this.userId);

  @override
  List<Object> get props => [taskId, userId];
}

class CreateCategoryEvent extends TaskEvent {
  final Category category;

  const CreateCategoryEvent(this.category);

  @override
  List<Object> get props => [category];
}

class UpdateCategoryEvent extends TaskEvent {
  final Category category;

  const UpdateCategoryEvent(this.category);

  @override
  List<Object> get props => [category];
}

class DeleteCategoryEvent extends TaskEvent {
  final String categoryId;
  final String userId;

  const DeleteCategoryEvent(this.categoryId, this.userId);

  @override
  List<Object> get props => [categoryId, userId];
}

class LoadTaskByIdEvent extends TaskEvent {
  final String taskId;
  final String userId;

  const LoadTaskByIdEvent(this.taskId, this.userId);

  @override
  List<Object> get props => [taskId, userId];
}

class FilterTasksEvent extends TaskEvent {
  final String query;

  const FilterTasksEvent(this.query);

  @override
  List<Object> get props => [query];
}
