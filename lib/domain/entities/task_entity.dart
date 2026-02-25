import 'package:equatable/equatable.dart';

class TaskEntity extends Equatable {
  final int? id;
  final String title;
  final String? description;
  final bool isCompleted;
  final String priority;
  final String category;
  final DateTime? dueDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TaskEntity({
    this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    required this.priority,
    required this.category,
    this.dueDate,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        isCompleted,
        priority,
        category,
        dueDate,
        createdAt,
        updatedAt,
      ];
}
