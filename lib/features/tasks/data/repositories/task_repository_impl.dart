import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'dart:io';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final storage.FirebaseStorage _storage = storage.FirebaseStorage.instance;

  @override
  Future<void> createTask(Task task) async {
    await _firestore
        .collection('users')
        .doc(task.userId)
        .collection('tasks')
        .doc(task.id)
        .set(task.toMap());
  }

  @override
  Future<List<Task>> getTasks(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .get();
    return snapshot.docs
        .map((doc) => Task.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<void> updateTask(Task task) async {
    await _firestore
        .collection('users')
        .doc(task.userId)
        .collection('tasks')
        .doc(task.id)
        .update(task.toMap());
  }

  @override
  Future<void> deleteTask(String taskId, String userId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  @override
  Future<void> createCategory(Category category) async {
    await _firestore
        .collection('users')
        .doc(category.userId)
        .collection('categories')
        .doc(category.id)
        .set(category.toMap());
  }

  @override
  Future<List<Category>> getCategories(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('categories')
          .get();
      final categories = snapshot.docs.map((doc) {
        final data = doc.data();
        return Category.fromMap(doc.id, data);
      }).toList();
      return categories;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateCategory(Category category) async {
    await _firestore
        .collection('users')
        .doc(category.userId)
        .collection('categories')
        .doc(category.id)
        .update(category.toMap());
  }

  @override
  Future<void> deleteCategory(String categoryId, String userId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('categories')
        .doc(categoryId)
        .delete();
  }

  @override
  Future<List<String>> uploadMedia(
    String taskId,
    String userId,
    List<File> files,
  ) async {
    final List<String> mediaUrls = [];
    for (final file in files) {
      final ref = _storage
          .ref()
          .child('users')
          .child(userId)
          .child('tasks')
          .child(taskId)
          .child(file.path.split('/').last);
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      mediaUrls.add(url);
    }
    return mediaUrls;
  }
}
