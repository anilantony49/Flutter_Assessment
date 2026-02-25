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
  TasksLoaded(this.tasks);
  @override
  List<Object?> get props => [tasks];
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
