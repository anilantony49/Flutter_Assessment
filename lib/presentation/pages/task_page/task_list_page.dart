import 'package:flutter/material.dart';
import 'package:flutter_assesment/domain/entities/task_entity.dart';
import 'package:flutter_assesment/presentation/bloc/task/task_bloc.dart';
import 'package:flutter_assesment/presentation/bloc/task/task_event.dart';
import 'package:flutter_assesment/presentation/bloc/task/task_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_assesment/utils/validations.dart';
import 'dart:async';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  bool _isConnected = true;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(() {
      context.read<TaskBloc>().add(SearchTasksEvent(_searchController.text));
    });

    // Connectivity listener
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      final connected = !results.contains(ConnectivityResult.none);
      if (connected && !_isConnected) {
        _syncTasks();
      }
      setState(() {
        _isConnected = connected;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        context.read<TaskBloc>().add(LoadMoreTasksEvent(user.uid));
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _loadTasks() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<TaskBloc>().add(LoadTasksEvent(user.uid));
    }
  }

  void _syncTasks() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<TaskBloc>().add(SyncTasksEvent(user.uid));
    }
  }

  Future<void> _onRefresh() async {
    _loadTasks();
    await Future.delayed(const Duration(seconds: 1));
  }

  void _showSortBottomSheet(String currentSort) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  ['Created Date', 'Due Date', 'Priority'].map((option) {
                    return ListTile(
                      leading: Icon(
                        currentSort == option
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color:
                            currentSort == option
                                ? Theme.of(context).primaryColor
                                : null,
                      ),
                      title: Text(option),
                      onTap: () {
                        context.read<TaskBloc>().add(SortTasksEvent(option));
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            final tasks = state is TasksLoaded ? state.tasks : [];
            return Column(
              children: [
                Text(
                  'My Tasks',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                    fontSize: 20,
                  ),
                ),
                if (tasks.isNotEmpty)
                  Text(
                    '${tasks.where((t) => !t.isCompleted).length} pending',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
              ],
            );
          },
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadTasks),
        ],
      ),
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is TaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final tasks = state is TasksLoaded ? state.filteredTasks : [];
          final filterStatus =
              state is TasksLoaded ? state.filterStatus : 'All';
          final sortBy = state is TasksLoaded ? state.sortBy : 'Created Date';
          final hasReachedMax =
              state is TasksLoaded ? state.hasReachedMax : false;

          return Column(
            children: [
              if (!_isConnected)
                Container(
                  width: double.infinity,
                  color: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'You are offline. Actions will sync when online.',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              // Search and Filter Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by title...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: theme.colorScheme.primary.withOpacity(0.6),
                        ),
                        filled: true,
                        fillColor:
                            isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ...['All', 'Pending', 'Completed'].map((status) {
                            final isSelected = filterStatus == status;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                selected: isSelected,
                                label: Text(status),
                                onSelected: (selected) {
                                  context.read<TaskBloc>().add(
                                    FilterTasksEvent(status),
                                  );
                                },
                                backgroundColor:
                                    isDark ? Colors.white10 : Colors.grey[200],
                                selectedColor: theme.colorScheme.primary
                                    .withOpacity(0.2),
                                checkmarkColor: theme.colorScheme.primary,
                                labelStyle: TextStyle(
                                  color:
                                      isSelected
                                          ? theme.colorScheme.primary
                                          : theme.textTheme.bodyMedium?.color,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            );
                          }),
                          const SizedBox(width: 8),
                          ActionChip(
                            avatar: const Icon(Icons.sort, size: 16),
                            label: Text(sortBy),
                            onPressed: () => _showSortBottomSheet(sortBy),
                            backgroundColor:
                                isDark ? Colors.white10 : Colors.grey[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: () {
                  if (state is TaskLoading && tasks.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (tasks.isEmpty) {
                    if (state is TaskLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 120),
                          FadeInUp(
                            duration: const Duration(milliseconds: 600),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _searchController.text.isEmpty &&
                                            filterStatus == 'All'
                                        ? Icons.add_task_rounded
                                        : Icons.search_off_rounded,
                                    size: 64,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  _searchController.text.isEmpty &&
                                          filterStatus == 'All'
                                      ? 'No tasks yet'
                                      : 'No results found',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 48,
                                  ),
                                  child: Text(
                                    _searchController.text.isEmpty &&
                                            filterStatus == 'All'
                                        ? 'Start your productivity journey by adding your first task today.'
                                        : 'Try adjusting your search or filters to find what you\'re looking for.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.6),
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                if (_searchController.text.isEmpty &&
                                    filterStatus == 'All')
                                  FilledButton.icon(
                                    onPressed: _showAddTaskDialog,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Your First Task'),
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                    ),
                                  )
                                else
                                  TextButton.icon(
                                    onPressed: () {
                                      _searchController.clear();
                                      context.read<TaskBloc>().add(
                                        FilterTasksEvent('All'),
                                      );
                                    },
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Clear All Filters'),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount:
                          hasReachedMax ? tasks.length : tasks.length + 1,
                      itemBuilder: (context, index) {
                        if (index >= tasks.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        final task = tasks[index];
                        final priorityColor = _getPriorityColor(task.priority);
                        return FadeInUp(
                          duration: const Duration(milliseconds: 300),
                          child: Dismissible(
                            key: Key(task.id?.toString() ?? index.toString()),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) async {
                              return await _showDeleteConfirmation(task);
                            },
                            background: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              alignment: Alignment.centerRight,
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color:
                                      isDark
                                          ? Colors.white10
                                          : Colors.grey[200]!,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                      isDark ? 0.2 : 0.05,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      Container(width: 4, color: priorityColor),
                                      Expanded(
                                        child: ListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 8,
                                              ),
                                          title: Text(
                                            task.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              decoration:
                                                  task.isCompleted
                                                      ? TextDecoration
                                                          .lineThrough
                                                      : null,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color:
                                                  task.isCompleted
                                                      ? Colors.grey
                                                      : theme
                                                          .textTheme
                                                          .titleMedium
                                                          ?.color,
                                            ),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (task.description != null &&
                                                  task.description!.isNotEmpty)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 4,
                                                        bottom: 8,
                                                      ),
                                                  child: Text(
                                                    task.description!,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: theme
                                                          .textTheme
                                                          .bodySmall
                                                          ?.color
                                                          ?.withOpacity(0.7),
                                                    ),
                                                  ),
                                                ),
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 4,
                                                children: [
                                                  _buildChip(
                                                    task.priority,
                                                    priorityColor,
                                                  ),
                                                  _buildChip(
                                                    task.category,
                                                    theme.colorScheme.secondary
                                                        .withOpacity(0.8),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.access_time,
                                                    size: 12,
                                                    color: theme
                                                        .colorScheme
                                                        .onSurface
                                                        .withOpacity(0.4),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  if (task.createdAt != null)
                                                    Text(
                                                      DateFormat(
                                                        'MMM d, h:mm a',
                                                      ).format(task.createdAt!),
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: theme
                                                            .colorScheme
                                                            .onSurface
                                                            .withOpacity(0.4),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          trailing: Transform.scale(
                                            scale: 1.2,
                                            child: Checkbox(
                                              value: task.isCompleted,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              activeColor:
                                                  theme.colorScheme.primary,
                                              onChanged: (val) {
                                                if (val != null) {
                                                  final user =
                                                      FirebaseAuth
                                                          .instance
                                                          .currentUser;
                                                  if (user != null &&
                                                      task.id != null) {
                                                    context
                                                        .read<TaskBloc>()
                                                        .add(
                                                          UpdateTaskEvent(
                                                            user.uid,
                                                            task.id!,
                                                            {
                                                              'is_completed':
                                                                  val,
                                                            },
                                                          ),
                                                        );
                                                  }
                                                }
                                              },
                                            ),
                                          ),
                                          onLongPress:
                                              () => _showDeleteDialog(task),
                                          onTap: () => _showTaskDetails(task),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }(),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskDialog(),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Task',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showTaskDetails(TaskEntity task) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                task.isCompleted
                                    ? Icons.check_circle_rounded
                                    : Icons.pending_actions_rounded,
                                size: 16,
                                color:
                                    task.isCompleted
                                        ? Colors.green
                                        : Colors.orangeAccent,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                task.isCompleted ? "Completed" : "In Progress",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      task.isCompleted
                                          ? Colors.green
                                          : Colors.orangeAccent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildChip(task.priority, _getPriorityColor(task.priority)),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  task.description ?? 'No description provided.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 24),
                Divider(color: theme.colorScheme.outlineVariant),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailRow(
                        Icons.category_rounded,
                        'Category',
                        task.category,
                        theme,
                      ),
                    ),
                    Expanded(
                      child: _buildDetailRow(
                        Icons.calendar_month_rounded,
                        'Due Date',
                        task.dueDate != null
                            ? DateFormat('MMM d, yyyy').format(task.dueDate!)
                            : "No due date",
                        theme,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.edit_rounded, size: 20),
                        label: const Text('Edit Task'),
                        onPressed: () {
                          Navigator.pop(context);
                          _showEditTaskDialog(task);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  void _showEditTaskDialog(TaskEntity task) {
    final titleController = TextEditingController(text: task.title);
    final descController = TextEditingController(text: task.description);
    String priority = task.priority;
    String category = task.category;
    DateTime? dueDate = task.dueDate;

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setModalState) => Padding(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    24,
                    24,
                    MediaQuery.of(context).viewInsets.bottom + 24,
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit Task',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: titleController,
                            decoration: InputDecoration(
                              labelText: 'Title',
                              prefixIcon: const Icon(Icons.title),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            validator: AppValidators.validateOnlyLetters,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: descController,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              prefixIcon: const Icon(
                                Icons.description_outlined,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            maxLines: 2,
                            validator: AppValidators.validateOnlyLetters,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: priority,
                                  decoration: InputDecoration(
                                    labelText: 'Priority',
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  items:
                                      ['Low', 'Medium', 'High']
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(e),
                                            ),
                                          )
                                          .toList(),
                                  onChanged:
                                      (val) =>
                                          setModalState(() => priority = val!),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: category,
                                  decoration: InputDecoration(
                                    labelText: 'Category',
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  items:
                                      [
                                            'Work',
                                            'Personal',
                                            'Health',
                                            'Finance',
                                            'Education',
                                            'Shopping',
                                            'Travel',
                                            'Others',
                                          ]
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(e),
                                            ),
                                          )
                                          .toList(),
                                  onChanged:
                                      (val) =>
                                          setModalState(() => category = val!),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.calendar_today),
                            title: Text(
                              dueDate == null
                                  ? 'No Due Date Selected'
                                  : 'Due Date: ${DateFormat('MMM d, yyyy').format(dueDate!)}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            trailing: TextButton(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: dueDate ?? DateTime.now(),
                                  firstDate: DateTime.now().subtract(
                                    const Duration(days: 365),
                                  ),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365 * 2),
                                  ),
                                );
                                if (picked != null) {
                                  setModalState(() => dueDate = picked);
                                }
                              },
                              child: Text(dueDate == null ? 'Set' : 'Change'),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: FilledButton(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  final user =
                                      FirebaseAuth.instance.currentUser;
                                  if (user != null && task.id != null) {
                                    context.read<TaskBloc>().add(
                                      UpdateTaskEvent(user.uid, task.id!, {
                                        'title': titleController.text.trim(),
                                        'description':
                                            descController.text.trim(),
                                        'priority': priority,
                                        'category': category,
                                        'due_date': dueDate?.toIso8601String(),
                                      }),
                                    );
                                  }
                                  Navigator.pop(context);
                                }
                              },
                              child: const Text('Update Task'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.redAccent;
      case 'Medium':
        return Colors.orangeAccent;
      case 'Low':
        return Colors.greenAccent;
      default:
        return Colors.grey;
    }
  }

  Future<bool?> _showDeleteConfirmation(TaskEntity task) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Delete Task'),
            ],
          ),
          content: Text(
            'Are you sure you want to permanently delete "${task.title}"? This action cannot be undone.',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(TaskEntity task) async {
    final confirm = await _showDeleteConfirmation(task);
    if (confirm == true) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && task.id != null) {
        if (mounted) {
          context.read<TaskBloc>().add(DeleteTaskEvent(user.uid, task.id!));
        }
      }
    }
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String priority = 'Medium';
    String category = 'Others';
    DateTime? dueDate;

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setModalState) => Padding(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    24,
                    24,
                    MediaQuery.of(context).viewInsets.bottom + 24,
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add New Task',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: titleController,
                            autofocus: true,
                            decoration: InputDecoration(
                              labelText: 'Title',
                              prefixIcon: const Icon(Icons.title),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            validator: AppValidators.validateOnlyLetters,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: descController,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              prefixIcon: const Icon(
                                Icons.description_outlined,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            maxLines: 2,
                            validator: AppValidators.validateOnlyLetters,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: priority,
                                  decoration: InputDecoration(
                                    labelText: 'Priority',
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  items:
                                      ['Low', 'Medium', 'High']
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(e),
                                            ),
                                          )
                                          .toList(),
                                  onChanged:
                                      (val) =>
                                          setModalState(() => priority = val!),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: category,
                                  decoration: InputDecoration(
                                    labelText: 'Category',
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  items:
                                      [
                                            'Work',
                                            'Personal',
                                            'Health',
                                            'Finance',
                                            'Education',
                                            'Shopping',
                                            'Travel',
                                            'Others',
                                          ]
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(e),
                                            ),
                                          )
                                          .toList(),
                                  onChanged:
                                      (val) =>
                                          setModalState(() => category = val!),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.calendar_today),
                            title: Text(
                              dueDate == null
                                  ? 'No Due Date Selected'
                                  : 'Due Date: ${DateFormat('MMM d, yyyy').format(dueDate!)}',
                            ),
                            trailing: TextButton(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365 * 2),
                                  ),
                                );
                                if (picked != null) {
                                  setModalState(() => dueDate = picked);
                                }
                              },
                              child: Text(dueDate == null ? 'Set' : 'Change'),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: FilledButton(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  final user =
                                      FirebaseAuth.instance.currentUser;
                                  if (user != null) {
                                    context.read<TaskBloc>().add(
                                      CreateTaskEvent(
                                        user.uid,
                                        TaskEntity(
                                          title: titleController.text.trim(),
                                          description:
                                              descController.text.trim(),
                                          priority: priority,
                                          category: category,
                                          isCompleted: false,
                                          createdAt: DateTime.now(),
                                          dueDate: dueDate,
                                        ),
                                      ),
                                    );
                                  }
                                  Navigator.pop(context);
                                }
                              },
                              child: const Text('Create Task'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          ),
    );
  }
}
