import 'package:taskly/features/tasks/domain/entities/task_entity.dart';
import 'package:taskly/features/tasks/domain/repositories/task_repository.dart';
import 'package:taskly/features/tasks/domain/usecases/usecases_interfaces/task_interfaces_usecases.dart';

class UpdateTask implements IUpdateTask {
  final TaskRepository _repository;

  UpdateTask(this._repository);

  @override
  Future<void> call(Task task) async {
    await _repository.updateTask(task);
  }
}
