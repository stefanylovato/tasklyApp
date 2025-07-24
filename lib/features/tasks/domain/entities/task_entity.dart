import 'package:equatable/equatable.dart';

enum TaskStatus { toDo, inProgress, done }

class Task extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime dueDate;
  final String categoryId;
  final String categoryName;
  final TaskStatus status;
  final List<String> mediaUrls;

  const Task({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.categoryId,
    required this.categoryName,
    required this.status,
    this.mediaUrls = const [],
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'title': title,
    'description': description,
    'dueDate': dueDate.toIso8601String(),
    'categoryId': categoryId,
    'categoryName': categoryName,
    'status': status.toString().split('.').last,
    'mediaUrls': mediaUrls,
  };

  static Task fromMap(String id, Map<String, dynamic> map) => Task(
    id: id,
    userId: map['userId'] as String,
    title: map['title'] as String,
    description: map['description'] as String,
    dueDate: DateTime.parse(map['dueDate'] as String),
    categoryId: map['categoryId'] as String,
    categoryName: map['categoryName'] as String,
    status: TaskStatus.values.firstWhere(
      (e) => e.toString().split('.').last == map['status'],
      orElse: () => TaskStatus.toDo,
    ),
    mediaUrls: (map['mediaUrls'] as List<dynamic>?)?.cast<String>() ?? [],
  );

  @override
  List<Object> get props => [
    id,
    userId,
    title,
    description,
    dueDate,
    categoryId,
    categoryName,
    status,
    mediaUrls,
  ];
}
