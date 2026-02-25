import 'package:dartz/dartz.dart';
import 'package:flutter_assesment/core/errors/failures.dart';
import 'package:flutter_assesment/data/datasources/task_local_data_source.dart';
import 'package:flutter_assesment/data/datasources/task_remote_data_source.dart';
import 'package:flutter_assesment/data/models/task_model.dart';
import 'package:flutter_assesment/domain/entities/task_entity.dart';
import 'package:flutter_assesment/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;
  final TaskLocalDataSource localDataSource;

  TaskRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks(String userId, {int skip = 0, int limit = 10}) async {
    try {
      final remoteTasks = await remoteDataSource.getTasks(userId, skip: skip, limit: limit);
      await localDataSource.cacheTasks(remoteTasks, isFirstPage: skip == 0);
      return Right(remoteTasks);
    } catch (e) {
      try {
        final localTasks = await localDataSource.getTasks();
        if (localTasks.isNotEmpty) {
          // If offline, we might return all cached tasks or just the first set.
          // For simplicity, we return everything cached if they are offline.
          return Right(localTasks);
        }
        return Left(ServerFailure(e.toString()));
      } catch (cacheError) {
        return Left(CacheFailure(cacheError.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> createTask(String userId, TaskEntity task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      final result = await remoteDataSource.createTask(userId, taskModel);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> updateTask(String userId, int taskId, Map<String, dynamic> data) async {
    try {
      final result = await remoteDataSource.updateTask(userId, taskId, data);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String userId, int taskId) async {
    try {
      await remoteDataSource.deleteTask(userId, taskId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
