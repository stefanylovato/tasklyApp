import 'dart:io';
import 'package:taskly/features/tasks/domain/repositories/task_repository.dart';
import 'package:taskly/features/tasks/domain/usecases/usecases_interfaces/task_interfaces_usecases.dart';

class UploadMedia implements IUploadMedia {
  final TaskRepository _repository;

  UploadMedia(this._repository);

  @override
  Future<List<String>> call(
    String taskId,
    String userId,
    List<File> files,
  ) async {
    return await _repository.uploadMedia(taskId, userId, files);
  }
}
