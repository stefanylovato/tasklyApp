import 'package:taskly/features/tasks/domain/entities/category_entity.dart';
import 'package:taskly/features/tasks/domain/repositories/task_repository.dart';
import 'package:taskly/features/tasks/domain/usecases/usecases_interfaces/task_interfaces_usecases.dart';

class UpdateCategory implements IUpdateCategory {
  final TaskRepository _repository;

  UpdateCategory(this._repository);

  @override
  Future<void> call(Category category) async {
    await _repository.updateCategory(category);
  }
}
