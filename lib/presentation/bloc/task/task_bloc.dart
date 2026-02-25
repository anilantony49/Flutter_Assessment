import 'package:flutter_assesment/domain/usecases/task_usecases.dart';
import 'package:flutter_assesment/presentation/bloc/task/task_event.dart';
import 'package:flutter_assesment/presentation/bloc/task/task_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasksUseCase getTasksUseCase;
  final CreateTaskUseCase createTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;

  int _currentSkip = 0;
  final int _limit = 10;

  TaskBloc({
    required this.getTasksUseCase,
    required this.createTaskUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
  }) : super(TaskInitial()) {
    on<LoadTasksEvent>((event, emit) async {
      emit(TaskLoading());
      _currentSkip = 0;
      final result = await getTasksUseCase(event.userId, skip: 0, limit: _limit);
      result.fold(
        (failure) => emit(TaskError(failure.message)),
        (tasks) {
          _currentSkip = tasks.length;
          emit(TasksLoaded(
            tasks: tasks,
            hasReachedMax: tasks.length < _limit,
          ));
        },
      );
    });

    on<LoadMoreTasksEvent>((event, emit) async {
      final currentState = state;
      if (currentState is TasksLoaded && !currentState.hasReachedMax && !currentState.isLoadingMore) {
        emit(currentState.copyWith(isLoadingMore: true));

        final result = await getTasksUseCase(event.userId, skip: _currentSkip, limit: _limit);
        result.fold(
          (failure) => emit(currentState.copyWith(isLoadingMore: false)),
          (newTasks) {
            if (newTasks.isEmpty) {
              emit(currentState.copyWith(hasReachedMax: true, isLoadingMore: false));
            } else {
              _currentSkip += newTasks.length;
              emit(TasksLoaded(
                tasks: currentState.tasks + newTasks,
                hasReachedMax: newTasks.length < _limit,
                isLoadingMore: false,
              ));
            }
          },
        );
      }
    });

    on<CreateTaskEvent>((event, emit) async {
      final result = await createTaskUseCase(event.userId, event.task);
      result.fold(
        (failure) => emit(TaskError(failure.message)),
        (task) {
          add(LoadTasksEvent(event.userId)); // Refresh list
          emit(TaskActionSuccess('Task created successfully'));
        },
      );
    });

    on<UpdateTaskEvent>((event, emit) async {
      final result = await updateTaskUseCase(event.userId, event.taskId, event.data);
      result.fold(
        (failure) => emit(TaskError(failure.message)),
        (task) {
          // Instead of full refresh, we could update the local state, but keeping it simple for now
          add(LoadTasksEvent(event.userId)); 
          emit(TaskActionSuccess('Task updated successfully'));
        },
      );
    });

    on<DeleteTaskEvent>((event, emit) async {
      final result = await deleteTaskUseCase(event.userId, event.taskId);
      result.fold(
        (failure) => emit(TaskError(failure.message)),
        (_) {
          add(LoadTasksEvent(event.userId)); // Refresh list
          emit(TaskActionSuccess('Task deleted successfully'));
        },
      );
    });
  }
}
