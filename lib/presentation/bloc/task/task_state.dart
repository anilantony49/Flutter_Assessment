import 'package:equatable/equatable.dart';
import 'package:flutter_assesment/domain/entities/task_entity.dart';

abstract class TaskState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TasksLoaded extends TaskState {
  final List<TaskEntity> tasks;
  final bool hasReachedMax;
  final bool isLoadingMore;

  TasksLoaded({
    required this.tasks,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [tasks, hasReachedMax, isLoadingMore];

  TasksLoaded copyWith({
    List<TaskEntity>? tasks,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return TasksLoaded(
      tasks: tasks ?? this.tasks,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class TaskActionSuccess extends TaskState {
  final String message;
  TaskActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class TaskError extends TaskState {
  final String message;
  TaskError(this.message);
  @override
  List<Object?> get props => [message];
}
