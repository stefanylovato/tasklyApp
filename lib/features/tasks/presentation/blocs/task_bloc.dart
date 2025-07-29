import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskly/features/tasks/domain/usecases/usecases_interfaces/task_interfaces_usecases.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final ICreateTask _createTask;
  final IGetTasks _getTasks;
  final IUpdateTask _updateTask;
  final IDeleteTask _deleteTask;
  final ICreateCategory _createCategory;
  final IGetCategories _getCategories;
  final IUpdateCategory _updateCategory;
  final IDeleteCategory _deleteCategory;
  final IUploadMedia _uploadMedia;
  DateTime? _lastCreateEvent;
  DateTime? _lastUpdateEvent;

  TaskBloc({
    required ICreateTask createTask,
    required IGetTasks getTasks,
    required IUpdateTask updateTask,
    required IDeleteTask deleteTask,
    required ICreateCategory createCategory,
    required IGetCategories getCategories,
    required IUpdateCategory updateCategory,
    required IDeleteCategory deleteCategory,
    required IUploadMedia uploadMedia,
  }) : _createTask = createTask,
       _getTasks = getTasks,
       _updateTask = updateTask,
       _deleteTask = deleteTask,
       _createCategory = createCategory,
       _getCategories = getCategories,
       _updateCategory = updateCategory,
       _deleteCategory = deleteCategory,
       _uploadMedia = uploadMedia,
       super(TaskInitial()) {
    on<LoadTasksEvent>(_onLoadTasks);
    on<LoadTaskByIdEvent>(_onLoadTaskById);
    on<CreateTaskEvent>(_onCreateTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<CreateCategoryEvent>(_onCreateCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
    on<FilterTasksEvent>(_onFilterTasks);
  }

  Future<List<String>> uploadMedia(
    String taskId,
    String userId,
    List<File> files,
  ) async {
    try {
      final mediaUrls = <String>[];
      for (var file in files) {
        if (!await file.exists()) {
          throw Exception('File does not exist: ${file.path}');
        }

        final urls = await _uploadMedia(taskId, userId, [file]);
        mediaUrls.addAll(urls);
      }

      return mediaUrls;
    } catch (e) {
      throw Exception('Failed to upload media: $e');
    }
  }

  Future<void> _onLoadTasks(
    LoadTasksEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());
    try {
      final tasks = await _getTasks(event.userId);
      final categories = await _getCategories(event.userId);

      emit(
        TaskLoaded(
          tasks: tasks,
          categories: categories,
          filteredTasks: tasks,
        ),
      );
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onLoadTaskById(
    LoadTaskByIdEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());
    try {
      final tasks = await _getTasks(event.userId);
      final categories = await _getCategories(event.userId);
      final task = tasks.firstWhere(
        (t) => t.id == event.taskId,
        orElse: () => throw Exception('Task not found'),
      );
      emit(
        TaskLoaded(
          tasks: tasks,
          categories: categories,
          filteredTasks: tasks,
          selectedTask: task,
        ),
      );
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onCreateTask(
    CreateTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    if (_lastCreateEvent != null &&
        DateTime.now().difference(_lastCreateEvent!).inMilliseconds < 1000) {
      return;
    }
    _lastCreateEvent = DateTime.now();

    emit(TaskLoading());
    try {
      await _createTask(event.task);
      final tasks = await _getTasks(event.task.userId);
      final currentState = state;
      emit(
        TaskLoaded(
          tasks: tasks,
          categories: currentState is TaskLoaded ? currentState.categories : [],
          filteredTasks: tasks,
          operationCompleted: 'created',
        ),
      );
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onUpdateTask(
    UpdateTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    if (_lastUpdateEvent != null &&
        DateTime.now().difference(_lastUpdateEvent!).inMilliseconds < 1000) {
      return;
    }
    _lastUpdateEvent = DateTime.now();

    emit(TaskLoading());
    try {
      await _updateTask(event.task);
      final tasks = await _getTasks(event.task.userId);
      final currentState = state;
      emit(
        TaskLoaded(
          tasks: tasks,
          categories: currentState is TaskLoaded ? currentState.categories : [],
          filteredTasks: tasks,
          operationCompleted: 'updated',
        ),
      );
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onDeleteTask(
    DeleteTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());
    try {
      await _deleteTask(event.taskId, event.userId);
      final tasks = await _getTasks(event.userId);
      final currentState = state;
      emit(
        TaskLoaded(
          tasks: tasks,
          categories: currentState is TaskLoaded ? currentState.categories : [],
          filteredTasks: tasks,
          operationCompleted: 'deleted',
        ),
      );
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onLoadCategories(
    LoadCategoriesEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());
    try {
      final categories = await _getCategories(event.userId);
      final currentState = state;
      emit(
        TaskLoaded(
          tasks: currentState is TaskLoaded ? currentState.tasks : [],
          categories: categories,
          filteredTasks: currentState is TaskLoaded ? currentState.tasks : [],
        ),
      );
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onCreateCategory(
    CreateCategoryEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());
    try {
      await _createCategory(event.category);
      final categories = await _getCategories(event.category.userId);
      final currentState = state;

      emit(
        TaskLoaded(
          tasks: currentState is TaskLoaded ? currentState.tasks : [],
          categories: categories,
          filteredTasks: currentState is TaskLoaded ? currentState.tasks : [],
          operationCompleted: 'category_created',
        ),
      );
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategoryEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());
    try {
      await _updateCategory(event.category);
      final categories = await _getCategories(event.category.userId);
      final currentState = state;

      emit(
        TaskLoaded(
          tasks: currentState is TaskLoaded ? currentState.tasks : [],
          categories: categories,
          filteredTasks: currentState is TaskLoaded ? currentState.tasks : [],
          operationCompleted: 'category_updated',
        ),
      );
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategoryEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());
    try {
      await _deleteCategory(event.categoryId, event.userId);
      final categories = await _getCategories(event.userId);
      final currentState = state;

      emit(
        TaskLoaded(
          tasks: currentState is TaskLoaded ? currentState.tasks : [],
          categories: categories,
          filteredTasks: currentState is TaskLoaded ? currentState.tasks : [],
          operationCompleted: 'category_deleted',
        ),
      );
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onFilterTasks(
    FilterTasksEvent event,
    Emitter<TaskState> emit,
  ) async {
    final currentState = state;
    if (currentState is TaskLoaded) {
      final query = event.query.toLowerCase();
      final filteredTasks = currentState.tasks.where((task) {
        return task.userId == event.userId &&
            (task.title.toLowerCase().contains(query) ||
                task.description.toLowerCase().contains(query) ||
                (task.categoryName.toLowerCase().contains(query)) ||
                task.status
                    .toString()
                    .split('.')
                    .last
                    .toLowerCase()
                    .contains(query));
      }).toList();
      emit(
        currentState.copyWith(
          filteredTasks: filteredTasks,
          operationCompleted: null,
        ),
      );
    } else {}
  }
}
