import 'package:dio/dio.dart';
import 'package:flutter_assesment/data/datasources/task_local_data_source.dart';
import 'package:flutter_assesment/data/datasources/task_remote_data_source.dart';
import 'package:flutter_assesment/data/repositories/task_repository_impl.dart';
import 'package:flutter_assesment/domain/repositories/task_repository.dart';
import 'package:flutter_assesment/domain/usecases/task_usecases.dart';
import 'package:flutter_assesment/presentation/bloc/task/task_bloc.dart';
import 'package:flutter_assesment/core/network/api_constants.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_assesment/core/network/network_info.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance; // sl: Service Locator

Future<void> init() async {
  // BLoC
  sl.registerFactory(
    () => TaskBloc(
      getTasksUseCase: sl(),
      createTaskUseCase: sl(),
      updateTaskUseCase: sl(),
      deleteTaskUseCase: sl(),
      syncTasksUseCase: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetTasksUseCase(sl()));
  sl.registerLazySingleton(() => CreateTaskUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTaskUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTaskUseCase(sl()));
  sl.registerLazySingleton(() => SyncTasksUseCase(sl()));

  // Repository
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<TaskRemoteDataSource>(
    () => TaskRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDataSourceImpl(),
  );

  // External
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton(
    () => Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    ),
  );
}
