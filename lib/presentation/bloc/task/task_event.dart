import 'package:equatable/equatable.dart';
import 'package:flutter_assesment/domain/entities/task_entity.dart';

abstract class TaskEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTasksEvent extends TaskEvent {
  final String userId;
  final int skip;
  final int limit;

  LoadTasksEvent(this.userId, {this.skip = 0, this.limit = 10});

  @override
  List<Object?> get props => [userId, skip, limit];
}

class CreateTaskEvent extends TaskEvent {
  final String userId;
  final TaskEntity task;
  CreateTaskEvent(this.userId, this.task);
  @override
  List<Object?> get props => [userId, task];
}

class UpdateTaskEvent extends TaskEvent {
  final String userId;
  final int taskId;
  final Map<String, dynamic> data;
  UpdateTaskEvent(this.userId, this.taskId, this.data);
  @override
  List<Object?> get props => [userId, taskId, data];
}

class DeleteTaskEvent extends TaskEvent {
  final String userId;
  final int taskId;
  DeleteTaskEvent(this.userId, this.taskId);
  @override
  List<Object?> get props => [userId, taskId];
}
