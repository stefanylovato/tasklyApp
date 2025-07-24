import 'package:taskly/features/tasks/domain/repositories/task_repository.dart';
import 'package:taskly/features/tasks/domain/usecases/usecases_interfaces/task_interfaces_usecases.dart';

class DeleteCategory implements IDeleteCategory {
  final TaskRepository _repository;

  DeleteCategory(this._repository);

  @override
  Future<void> call(String categoryId, String userId) async {
    await _repository.deleteCategory(categoryId, userId);
  }
}
