import 'package:dartz/dartz.dart';
import 'package:flutter_assesment/core/errors/failures.dart';
import 'package:flutter_assesment/domain/entities/task_entity.dart';
import 'package:flutter_assesment/domain/repositories/task_repository.dart';

class GetTasksUseCase {
  final TaskRepository repository;
  GetTasksUseCase(this.repository);

  Future<Either<Failure, List<TaskEntity>>> call(String userId, {int skip = 0, int limit = 10}) {
    return repository.getTasks(userId, skip: skip, limit: limit);
  }
}

class CreateTaskUseCase {
  final TaskRepository repository;
  CreateTaskUseCase(this.repository);

  Future<Either<Failure, TaskEntity>> call(String userId, TaskEntity task) {
    return repository.createTask(userId, task);
  }
}

class UpdateTaskUseCase {
  final TaskRepository repository;
  UpdateTaskUseCase(this.repository);

  Future<Either<Failure, TaskEntity>> call(String userId, int taskId, Map<String, dynamic> data) {
    return repository.updateTask(userId, taskId, data);
  }
}

class DeleteTaskUseCase {
  final TaskRepository repository;
  DeleteTaskUseCase(this.repository);

  Future<Either<Failure, void>> call(String userId, int taskId) {
    return repository.deleteTask(userId, taskId);
  }
}

class SyncTasksUseCase {
  final TaskRepository repository;
  SyncTasksUseCase(this.repository);

  Future<void> call(String userId) {
    return repository.syncPendingActions(userId);
  }
}
