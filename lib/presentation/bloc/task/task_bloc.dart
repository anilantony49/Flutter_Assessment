import 'package:flutter_assesment/domain/entities/task_entity.dart';
import 'package:flutter_assesment/domain/usecases/task_usecases.dart';
import 'package:flutter_assesment/presentation/bloc/task/task_event.dart';
import 'package:flutter_assesment/presentation/bloc/task/task_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasksUseCase getTasksUseCase;
  final CreateTaskUseCase createTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;

  final SyncTasksUseCase syncTasksUseCase;

  int _currentSkip = 0;
  final int _limit = 10;

  TaskBloc({
    required this.getTasksUseCase,
    required this.createTaskUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
    required this.syncTasksUseCase,
  }) : super(TaskInitial()) {
    on<LoadTasksEvent>((event, emit) async {
      final currentState = state;
      String filterStatus = 'All';
      String sortBy = 'Created Date';
      String searchQuery = '';

      if (currentState is TasksLoaded) {
        filterStatus = currentState.filterStatus;
        sortBy = currentState.sortBy;
        searchQuery = currentState.searchQuery;
      } else {
        emit(TaskLoading());
      }

      _currentSkip = 0;
      final result = await getTasksUseCase(
        event.userId,
        skip: 0,
        limit: _limit,
      );

      result.fold((failure) => emit(TaskError(failure.message)), (tasks) {
        _currentSkip = tasks.length;
        final filtered = _applyFilter(tasks, filterStatus, sortBy, searchQuery);
        emit(
          TasksLoaded(
            tasks: tasks,
            filteredTasks: filtered,
            hasReachedMax: tasks.length < _limit,
            filterStatus: filterStatus,
            sortBy: sortBy,
            searchQuery: searchQuery,
          ),
        );
      });
    });

    on<LoadMoreTasksEvent>((event, emit) async {
      final currentState = state;
      if (currentState is TasksLoaded &&
          !currentState.hasReachedMax &&
          !currentState.isLoadingMore) {
        emit(currentState.copyWith(isLoadingMore: true));

        final result = await getTasksUseCase(
          event.userId,
          skip: _currentSkip,
          limit: _limit,
        );
        result.fold(
          (failure) => emit(currentState.copyWith(isLoadingMore: false)),
          (newTasks) {
            if (newTasks.isEmpty) {
              emit(
                currentState.copyWith(
                  hasReachedMax: true,
                  isLoadingMore: false,
                ),
              );
            } else {
              _currentSkip += newTasks.length;
              final allTasks = currentState.tasks + newTasks;
              final filtered = _applyFilter(
                allTasks,
                currentState.filterStatus,
                currentState.sortBy,
                currentState.searchQuery,
              );
              emit(
                TasksLoaded(
                  tasks: allTasks,
                  filteredTasks: filtered,
                  hasReachedMax: newTasks.length < _limit,
                  isLoadingMore: false,
                  filterStatus: currentState.filterStatus,
                  sortBy: currentState.sortBy,
                  searchQuery: currentState.searchQuery,
                ),
              );
            }
          },
        );
      }
    });

    on<CreateTaskEvent>((event, emit) async {
      final result = await createTaskUseCase(event.userId, event.task);
      result.fold((failure) => emit(TaskError(failure.message)), (task) {
        add(LoadTasksEvent(event.userId)); // Refresh list
        emit(TaskActionSuccess('Task created successfully'));
      });
    });

    on<UpdateTaskEvent>((event, emit) async {
      final result = await updateTaskUseCase(
        event.userId,
        event.taskId,
        event.data,
      );
      result.fold((failure) => emit(TaskError(failure.message)), (task) {
        // Instead of full refresh, we could update the local state, but keeping it simple for now
        add(LoadTasksEvent(event.userId));
        emit(TaskActionSuccess('Task updated successfully'));
      });
    });

    on<DeleteTaskEvent>((event, emit) async {
      final result = await deleteTaskUseCase(event.userId, event.taskId);
      result.fold((failure) => emit(TaskError(failure.message)), (_) {
        add(LoadTasksEvent(event.userId)); // Refresh list
        emit(TaskActionSuccess('Task deleted successfully'));
      });
    });

    on<SyncTasksEvent>((event, emit) async {
      await syncTasksUseCase(event.userId);
      add(LoadTasksEvent(event.userId)); // Refresh list after sync
    });

    on<SearchTasksEvent>((event, emit) {
      if (state is TasksLoaded) {
        final s = state as TasksLoaded;
        final filtered = _applyFilter(
          s.tasks,
          s.filterStatus,
          s.sortBy,
          event.query,
        );
        emit(s.copyWith(filteredTasks: filtered, searchQuery: event.query));
      }
    });

    on<FilterTasksEvent>((event, emit) {
      if (state is TasksLoaded) {
        final s = state as TasksLoaded;
        final filtered = _applyFilter(
          s.tasks,
          event.status,
          s.sortBy,
          s.searchQuery,
        );
        emit(s.copyWith(filteredTasks: filtered, filterStatus: event.status));
      }
    });

    on<SortTasksEvent>((event, emit) {
      if (state is TasksLoaded) {
        final s = state as TasksLoaded;
        final filtered = _applyFilter(
          s.tasks,
          s.filterStatus,
          event.sortBy,
          s.searchQuery,
        );
        emit(s.copyWith(filteredTasks: filtered, sortBy: event.sortBy));
      }
    });
  }

  List<TaskEntity> _applyFilter(
    List<TaskEntity> tasks,
    String status,
    String sortBy,
    String query,
  ) {
    var filtered =
        tasks.where((task) {
          final matchesSearch = task.title.toLowerCase().contains(
            query.toLowerCase(),
          );
          bool matchesFilter = true;
          if (status == 'Completed') {
            matchesFilter = task.isCompleted;
          } else if (status == 'Pending') {
            matchesFilter = !task.isCompleted;
          }
          return matchesSearch && matchesFilter;
        }).toList();

    if (sortBy == 'Created Date') {
      filtered.sort((a, b) {
        final dateA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateB.compareTo(dateA);
      });
    } else if (sortBy == 'Due Date') {
      filtered.sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
    } else if (sortBy == 'Priority') {
      final weights = {'High': 3, 'Medium': 2, 'Low': 1};
      filtered.sort((a, b) {
        final weightA = weights[a.priority] ?? 0;
        final weightB = weights[b.priority] ?? 0;
        return weightB.compareTo(weightA);
      });
    }
    return filtered;
  }
}
