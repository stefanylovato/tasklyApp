import 'package:taskly/features/tasks/domain/entities/category_entity.dart';
import 'package:taskly/features/tasks/domain/repositories/task_repository.dart';
import 'package:taskly/features/tasks/domain/usecases/usecases_interfaces/task_interfaces_usecases.dart';

class CreateCategory implements ICreateCategory {
  final TaskRepository _repository;

  CreateCategory(this._repository);

  @override
  Future<void> call(Category category) async {
    await _repository.createCategory(category);
  }
}
