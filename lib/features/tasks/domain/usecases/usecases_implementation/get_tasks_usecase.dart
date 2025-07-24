import 'package:taskly/features/tasks/domain/entities/task_entity.dart';
import 'package:taskly/features/tasks/domain/repositories/task_repository.dart';
import 'package:taskly/features/tasks/domain/usecases/usecases_interfaces/task_interfaces_usecases.dart';

class GetTasks implements IGetTasks {
  final TaskRepository _repository;

  GetTasks(this._repository);

  @override
  Future<List<Task>> call(String userId) async {
    return await _repository.getTasks(userId);
  }
}
