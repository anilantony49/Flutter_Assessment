import 'package:equatable/equatable.dart';
import 'package:flutter_assesment/domain/entities/task_entity.dart';

abstract class TaskState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TasksLoaded extends TaskState {
  final List<TaskEntity> tasks; // All tasks from repo
  final List<TaskEntity> filteredTasks; // Tasks to display
  final bool hasReachedMax;
  final bool isLoadingMore;
  final String filterStatus;
  final String sortBy;
  final String searchQuery;

  TasksLoaded({
    required this.tasks,
    required this.filteredTasks,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.filterStatus = 'All',
    this.sortBy = 'Created Date',
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [
        tasks,
        filteredTasks,
        hasReachedMax,
        isLoadingMore,
        filterStatus,
        sortBy,
        searchQuery,
      ];

  TasksLoaded copyWith({
    List<TaskEntity>? tasks,
    List<TaskEntity>? filteredTasks,
    bool? hasReachedMax,
    bool? isLoadingMore,
    String? filterStatus,
    String? sortBy,
    String? searchQuery,
  }) {
    return TasksLoaded(
      tasks: tasks ?? this.tasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      filterStatus: filterStatus ?? this.filterStatus,
      sortBy: sortBy ?? this.sortBy,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class TaskActionSuccess extends TaskState {
  final String message;
  TaskActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class TaskError extends TaskState {
  final String message;
  TaskError(this.message);
  @override
  List<Object?> get props => [message];
}
