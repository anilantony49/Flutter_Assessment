import 'package:dio/dio.dart';
import 'package:flutter_assesment/core/network/api_constants.dart';
import 'package:flutter_assesment/data/models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasks(String userId, {int skip, int limit});
  Future<TaskModel> createTask(String userId, TaskModel task);
  Future<TaskModel> updateTask(String userId, int taskId, Map<String, dynamic> data);
  Future<void> deleteTask(String userId, int taskId);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final Dio dio;

  TaskRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<TaskModel>> getTasks(String userId, {int skip = 0, int limit = 10}) async {
    try {
      // API Doc shows collection with trailing slash: /tasks/
      final response = await dio.get(
        '${ApiConstants.tasks}/',
        queryParameters: {
          'user_id': userId,
          'skip': skip,
          'limit': limit,
        },
      );
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final List data = response.data['data'];
        return data.map((json) => TaskModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load tasks');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TaskModel> createTask(String userId, TaskModel task) async {
    try {
      // API Doc shows collection with trailing slash: /tasks/
      final response = await dio.post(
        '${ApiConstants.tasks}/',
        queryParameters: {'user_id': userId},
        data: task.toJson(),
      );
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return TaskModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create task');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TaskModel> updateTask(String userId, int taskId, Map<String, dynamic> data) async {
    try {
      // API Doc: /tasks/{task_id}
      final response = await dio.put(
        '${ApiConstants.tasks}/$taskId',
        queryParameters: {'user_id': userId},
        data: data,
      );
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return TaskModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update task');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteTask(String userId, int taskId) async {
    try {
      // API Doc: /tasks/{task_id}
      final response = await dio.delete(
        '${ApiConstants.tasks}/$taskId',
        queryParameters: {'user_id': userId},
      );
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to delete task');
      }
    } catch (e) {
      rethrow;
    }
  }
}
