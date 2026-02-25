import 'dart:convert';
import 'package:flutter_assesment/data/models/task_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getTasks();
  Future<void> cacheTasks(List<TaskModel> tasks, {bool isFirstPage = false});
  Future<void> addTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(int taskId);
  Future<void> clearCache();

  // Offline Sync Actions
  Future<void> addPendingAction(String action, Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> getPendingActions();
  Future<void> deletePendingAction(int id);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3, // Incremented version for pending_actions
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        is_completed INTEGER NOT NULL,
        priority TEXT NOT NULL,
        category TEXT NOT NULL,
        due_date TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE pending_actions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        action TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE tasks ADD COLUMN created_at TEXT');
      await db.execute('ALTER TABLE tasks ADD COLUMN updated_at TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE pending_actions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          action TEXT NOT NULL,
          data TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
    }
  }

  @override
  Future<List<TaskModel>> getTasks() async {
    final db = await database;
    final result = await db.query('tasks', orderBy: 'created_at DESC');
    return result.map((json) => TaskModel.fromLocalMap(json)).toList();
  }

  @override
  Future<void> cacheTasks(List<TaskModel> tasks, {bool isFirstPage = false}) async {
    final db = await database;
    final batch = db.batch();
    
    if (isFirstPage) {
      batch.delete('tasks');
    }
    
    for (var task in tasks) {
      batch.insert(
        'tasks', 
        task.toLocalMap(), 
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> addTask(TaskModel task) async {
    final db = await database;
    await db.insert(
      'tasks',
      task.toLocalMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    final db = await database;

    // Get existing task to preserve fields not sent from API
    final existing = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [task.id],
    );

    if (existing.isNotEmpty) {
      final existingModel = TaskModel.fromLocalMap(existing.first);
      final mergedTask = task.copyWith(
        createdAt: task.createdAt ?? existingModel.createdAt,
      );
      await db.update(
        'tasks',
        mergedTask.toLocalMap(),
        where: 'id = ?',
        whereArgs: [task.id],
      );
    } else {
      await db.update(
        'tasks',
        task.toLocalMap(),
        where: 'id = ?',
        whereArgs: [task.id],
      );
    }
  }

  @override
  Future<void> deleteTask(int taskId) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [taskId]);
  }

  @override
  Future<void> clearCache() async {
    final db = await database;
    await db.delete('tasks');
  }

  @override
  Future<void> addPendingAction(String action, Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('pending_actions', {
      'action': action,
      'data': jsonEncode(data),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingActions() async {
    final db = await database;
    return await db.query('pending_actions', orderBy: 'id ASC');
  }

  @override
  Future<void> deletePendingAction(int id) async {
    final db = await database;
    await db.delete('pending_actions', where: 'id = ?', whereArgs: [id]);
  }
}
