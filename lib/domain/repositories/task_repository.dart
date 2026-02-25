import 'package:dartz/dartz.dart';
import 'package:flutter_assesment/core/errors/failures.dart';
import 'package:flutter_assesment/domain/entities/task_entity.dart';

abstract class TaskRepository {
  Future<Either<Failure, List<TaskEntity>>> getTasks(String userId, {int skip, int limit});
  Future<Either<Failure, TaskEntity>> createTask(String userId, TaskEntity task);
  Future<Either<Failure, TaskEntity>> updateTask(String userId, int taskId, Map<String, dynamic> data);
  Future<Either<Failure, void>> deleteTask(String userId, int taskId);
}
