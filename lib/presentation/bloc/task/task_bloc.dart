import 'package:flutter_assesment/domain/usecases/task_usecases.dart';
import 'package:flutter_assesment/presentation/bloc/task/task_event.dart';
import 'package:flutter_assesment/presentation/bloc/task/task_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasksUseCase getTasksUseCase;
  final CreateTaskUseCase createTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;

  TaskBloc({
    required this.getTasksUseCase,
    required this.createTaskUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
  }) : super(TaskInitial()) {
    on<LoadTasksEvent>((event, emit) async {
      emit(TaskLoading());
      final result = await getTasksUseCase(event.userId);
      result.fold(
        (failure) => emit(TaskError(failure.message)),
        (tasks) => emit(TasksLoaded(tasks)),
      );
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
          add(LoadTasksEvent(event.userId)); // Refresh list
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
