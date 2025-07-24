import 'package:equatable/equatable.dart';
import 'package:taskly/features/tasks/domain/entities/category_entity.dart';
import 'package:taskly/features/tasks/domain/entities/task_entity.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<Task> tasks;
  final List<Category> categories;
  final List<Task> filteredTasks;
  final Task? selectedTask;
  final String? operationCompleted;
  final List<String> mediaUrls;

  const TaskLoaded({
    required this.tasks,
    required this.categories,
    required this.filteredTasks,
    this.selectedTask,
    this.operationCompleted,
    this.mediaUrls = const [],
  });

  TaskLoaded copyWith({
    List<Task>? tasks,
    List<Category>? categories,
    List<Task>? filteredTasks,
    Task? selectedTask,
    String? operationCompleted,
    List<String>? mediaUrls,
  }) {
    return TaskLoaded(
      tasks: tasks ?? this.tasks,
      categories: categories ?? this.categories,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      selectedTask: selectedTask ?? this.selectedTask,
      operationCompleted: operationCompleted ?? this.operationCompleted,
      mediaUrls: mediaUrls ?? this.mediaUrls,
    );
  }

  @override
  List<Object?> get props => [
    tasks,
    categories,
    filteredTasks,
    selectedTask,
    operationCompleted,
    mediaUrls,
  ];
}

class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object> get props => [message];
}
