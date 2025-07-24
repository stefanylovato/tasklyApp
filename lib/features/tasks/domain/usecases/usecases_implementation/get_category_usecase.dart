import 'package:taskly/features/tasks/domain/entities/category_entity.dart';
import 'package:taskly/features/tasks/domain/repositories/task_repository.dart';
import 'package:taskly/features/tasks/domain/usecases/usecases_interfaces/task_interfaces_usecases.dart';

class GetCategories implements IGetCategories {
  final TaskRepository _repository;

  GetCategories(this._repository);

  @override
  Future<List<Category>> call(String userId) async {
    return await _repository.getCategories(userId);
  }
}
