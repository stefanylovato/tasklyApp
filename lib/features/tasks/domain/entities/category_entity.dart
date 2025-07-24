import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String userId;
  final String name;

  const Category({
    required this.id,
    required this.userId,
    required this.name,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'name': name,
  };

  static Category fromMap(String id, Map<String, dynamic> map) => Category(
    id: id,
    userId: map['userId'] as String,
    name: map['name'] as String,
  );

  @override
  List<Object> get props => [id, userId, name];
}
