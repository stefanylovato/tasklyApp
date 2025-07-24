import 'package:taskly/features/tasks/domain/repositories/task_repository.dart';
import 'package:taskly/features/tasks/domain/usecases/usecases_interfaces/task_interfaces_usecases.dart';

class DeleteTask implements IDeleteTask {
  final TaskRepository _repository;

  DeleteTask(this._repository);

  @override
  Future<void> call(String taskId, String userId) async {
    await _repository.deleteTask(taskId, userId);
  }
}
