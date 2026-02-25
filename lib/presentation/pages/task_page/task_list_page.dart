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
import 'dart:async';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _filterStatus = 'All'; // All, Completed, Pending

  List<TaskEntity> _allTasks = [];
  bool _hasReachedMax = false;
  String _sortBy = 'Created Date'; // Created Date, Due Date, Priority
  
  bool _isConnected = true;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(() {
      setState(() {}); // Trigger rebuild to filter client-side
    });
    
    // Connectivity listener
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      final connected = !results.contains(ConnectivityResult.none);
      if (connected && !_isConnected) {
        // Just restored connection
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

  List<TaskEntity> _getFilteredTasks(List<TaskEntity> tasks) {
    final filtered =
        tasks.where((task) {
          final matchesSearch = task.title.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );
          bool matchesFilter = true;
          if (_filterStatus == 'Completed') {
            matchesFilter = task.isCompleted;
          } else if (_filterStatus == 'Pending') {
            matchesFilter = !task.isCompleted;
          }
          return matchesSearch && matchesFilter;
        }).toList();

    // Sorting logic
    if (_sortBy == 'Created Date') {
      filtered.sort((a, b) {
        final dateA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateB.compareTo(dateA); // Newest first
      });
    } else if (_sortBy == 'Due Date') {
      filtered.sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!); // Earliest first
      });
    } else if (_sortBy == 'Priority') {
      final weights = {'High': 3, 'Medium': 2, 'Low': 1};
      filtered.sort((a, b) {
        final weightA = weights[a.priority] ?? 0;
        final weightB = weights[b.priority] ?? 0;
        return weightB.compareTo(weightA); // Highest first
      });
    }

    return filtered;
  }

  void _showSortBottomSheet() {
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
                        _sortBy == option
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color:
                            _sortBy == option
                                ? Theme.of(context).primaryColor
                                : null,
                      ),
                      title: Text(option),
                      onTap: () {
                        setState(() {
                          _sortBy = option;
                        });
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
        title: const Text(
          'My Tasks',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadTasks),
        ],
      ),
      body: Column(
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
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: isDark ? Colors.white10 : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...['All', 'Pending', 'Completed'].map((status) {
                        final isSelected = _filterStatus == status;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            selected: isSelected,
                            label: Text(status),
                            onSelected: (selected) {
                              setState(() {
                                _filterStatus = status;
                              });
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
                        label: Text(_sortBy),
                        onPressed: _showSortBottomSheet,
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
            child: BlocConsumer<TaskBloc, TaskState>(
              listener: (context, state) {
                if (state is TasksLoaded) {
                  _allTasks = state.tasks;
                  _hasReachedMax = state.hasReachedMax;
                } else if (state is TaskActionSuccess) {
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
                if (state is TaskLoading && _allTasks.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredTasks = _getFilteredTasks(_allTasks);

                if (filteredTasks.isEmpty) {
                  if (_allTasks.isEmpty) {
                    if (state is TaskLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: ListView(
                        children: const [
                          SizedBox(height: 100),
                          Center(child: Text('No tasks found. Add some!')),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView(
                      children: const [
                        SizedBox(height: 100),
                        Center(
                          child: Text('No matching tasks for this filter.'),
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
                        _hasReachedMax
                            ? filteredTasks.length
                            : filteredTasks.length + 1,
                    itemBuilder: (context, index) {
                      if (index >= filteredTasks.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final task = filteredTasks[index];
                      return FadeInUp(
                        duration: const Duration(milliseconds: 300),
                        child: Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(
                              color:
                                  isDark ? Colors.white10 : Colors.grey[200]!,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                decoration:
                                    task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                fontWeight: FontWeight.bold,
                                color:
                                    task.isCompleted
                                        ? Colors.grey
                                        : theme.textTheme.titleMedium?.color,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (task.description != null &&
                                    task.description!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      task.description!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: theme.textTheme.bodySmall?.color,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _buildChip(
                                      task.priority,
                                      _getPriorityColor(task.priority),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildChip(task.category, Colors.blueGrey),
                                    const Spacer(),
                                    if (task.createdAt != null)
                                      Text(
                                        DateFormat(
                                          'MMM d, h:mm a',
                                        ).format(task.createdAt!),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Checkbox(
                              value: task.isCompleted,
                              shape: const CircleBorder(),
                              onChanged: (val) {
                                if (val != null) {
                                  final user =
                                      FirebaseAuth.instance.currentUser;
                                  if (user != null && task.id != null) {
                                    context.read<TaskBloc>().add(
                                      UpdateTaskEvent(user.uid, task.id!, {
                                        'is_completed': val,
                                      }),
                                    );
                                  }
                                }
                              },
                            ),
                            onLongPress: () => _showDeleteDialog(task),
                            onTap: () => _showTaskDetails(task),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 4,
        onPressed: () => _showAddTaskDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showTaskDetails(TaskEntity task) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildChip(task.priority, _getPriorityColor(task.priority)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  task.description ?? 'No description provided.',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(
                      Icons.category_outlined,
                      size: 20,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text('Category: ${task.category}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Due Date: ${task.dueDate != null ? DateFormat('MMM d, yyyy').format(task.dueDate!) : "No Due Date"}',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      task.isCompleted
                          ? Icons.check_circle_outline
                          : Icons.radio_button_unchecked,
                      size: 20,
                      color: task.isCompleted ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Status: ${task.isCompleted ? "Completed" : "Pending"}',
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit'),
                        onPressed: () {
                          Navigator.pop(context);
                          _showEditTaskDialog(task);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  void _showEditTaskDialog(TaskEntity task) {
    final titleController = TextEditingController(text: task.title);
    final descController = TextEditingController(text: task.description);
    String priority = task.priority;
    String category = task.category;
    DateTime? dueDate = task.dueDate;

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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Edit Task',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          prefixIcon: const Icon(Icons.title),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: descController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          prefixIcon: const Icon(Icons.description_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        maxLines: 2,
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
                                  (val) => setModalState(() => priority = val!),
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
                                  (val) => setModalState(() => category = val!),
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
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {
                            if (titleController.text.isNotEmpty) {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null && task.id != null) {
                                context.read<TaskBloc>().add(
                                  UpdateTaskEvent(user.uid, task.id!, {
                                    'title': titleController.text,
                                    'description': descController.text,
                                    'priority': priority,
                                    'category': category,
                                    'due_date': dueDate?.toIso8601String(),
                                  }),
                                );
                              }
                              Navigator.pop(context);
                            }
                          },
                          child: const Text(
                            'Update Task',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
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

  void _showDeleteDialog(TaskEntity task) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Text('Delete Task'),
            content: const Text(
              'Are you sure you want to permanentaly delete this task?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null && task.id != null) {
                    context.read<TaskBloc>().add(
                      DeleteTaskEvent(user.uid, task.id!),
                    );
                  }
                  Navigator.pop(context);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String priority = 'Medium';
    String category = 'Others';
    DateTime? dueDate;

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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add New Task',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: titleController,
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          prefixIcon: const Icon(Icons.title),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: descController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          prefixIcon: const Icon(Icons.description_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        maxLines: 2,
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
                                  (val) => setModalState(() => priority = val!),
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
                                  (val) => setModalState(() => category = val!),
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
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {
                            if (titleController.text.isNotEmpty) {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                context.read<TaskBloc>().add(
                                  CreateTaskEvent(
                                    user.uid,
                                    TaskEntity(
                                      title: titleController.text,
                                      description: descController.text,
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
                          child: const Text(
                            'Create Task',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }
}
