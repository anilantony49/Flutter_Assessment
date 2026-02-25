import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter_assesment/core/errors/failures.dart';
import 'package:flutter_assesment/core/network/network_info.dart';
import 'package:flutter_assesment/data/datasources/task_local_data_source.dart';
import 'package:flutter_assesment/data/datasources/task_remote_data_source.dart';
import 'package:flutter_assesment/data/models/task_model.dart';
import 'package:flutter_assesment/domain/entities/task_entity.dart';
import 'package:flutter_assesment/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;
  final TaskLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  TaskRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<void> syncPendingActions(String userId) async {
    if (!await networkInfo.isConnected) return;

    final pending = await localDataSource.getPendingActions();
    if (pending.isEmpty) return;

    for (var actionMap in pending) {
      final id = actionMap['id'];
      final action = actionMap['action'];
      final Map<String, dynamic> data = jsonDecode(actionMap['data']);

      try {
        if (action == 'CREATE') {
          final taskModel = TaskModel.fromJson(data);
          await remoteDataSource.createTask(userId, taskModel);
        } else if (action == 'UPDATE') {
          final taskId = data['id'];
          final updateData = Map<String, dynamic>.from(data)..remove('id');
          await remoteDataSource.updateTask(userId, taskId, updateData);
        } else if (action == 'DELETE') {
          await remoteDataSource.deleteTask(userId, data['id']);
        }
        await localDataSource.deletePendingAction(id);
      } catch (e) {
        // Log or handle individual sync failure (maybe retry later)
        continue;
      }
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks(
    String userId, {
    int skip = 0,
    int limit = 10,
  }) async {
    if (await networkInfo.isConnected) {
      // Try to sync pending items before fetching
      await syncPendingActions(userId);
      try {
        final remoteTasks = await remoteDataSource.getTasks(
          userId,
          skip: skip,
          limit: limit,
        );
        await localDataSource.cacheTasks(remoteTasks, isFirstPage: skip == 0);
        return Right(remoteTasks);
      } catch (e) {
        // Fallback to local if remote fails even if connected
        return _getLocalTasks();
      }
    } else {
      return _getLocalTasks();
    }
  }

  Future<Either<Failure, List<TaskEntity>>> _getLocalTasks() async {
    try {
      final localTasks = await localDataSource.getTasks();
      return Right(localTasks);
    } catch (cacheError) {
      return Left(CacheFailure(cacheError.toString()));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> createTask(
    String userId,
    TaskEntity task,
  ) async {
    final taskModel = TaskModel.fromEntity(task);
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.createTask(userId, taskModel);
        await localDataSource.addTask(TaskModel.fromEntity(result));
        return Right(result);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      // Offline: Add to local DB and queue for sync
      // Note: We don't have a server-side ID yet, so we might need to handle this.
      // For simplicity, we'll tell the user it will sync when online.
      await localDataSource.addPendingAction('CREATE', taskModel.toJson());
      return Right(task); // Optimistic update
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> updateTask(
    String userId,
    int taskId,
    Map<String, dynamic> data,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.updateTask(userId, taskId, data);
        await localDataSource.updateTask(TaskModel.fromEntity(result));
        return Right(result);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      // Offline: Apply locally and queue
      final pendingData = Map<String, dynamic>.from(data)..['id'] = taskId;
      await localDataSource.addPendingAction('UPDATE', pendingData);
      // We can't return the full updated entity easily without refetching from loal,
      // but for Bloc state it might be enough.
      return Left(ServerFailure('Offline: Action queued for sync.'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String userId, int taskId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteTask(userId, taskId);
        await localDataSource.deleteTask(taskId);
        return const Right(null);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      await localDataSource.addPendingAction('DELETE', {'id': taskId});
      await localDataSource.deleteTask(taskId);
      return const Right(null);
    }
  }
}
