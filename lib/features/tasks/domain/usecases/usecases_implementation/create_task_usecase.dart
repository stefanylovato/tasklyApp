import 'package:taskly/features/tasks/domain/entities/task_entity.dart';
import 'package:taskly/features/tasks/domain/repositories/task_repository.dart';
import 'package:taskly/features/tasks/domain/usecases/usecases_interfaces/task_interfaces_usecases.dart';

class CreateTask implements ICreateTask {
  final TaskRepository _repository;

  CreateTask(this._repository);

  @override
  Future<void> call(Task task) async {
    await _repository.createTask(task);
  }
}
