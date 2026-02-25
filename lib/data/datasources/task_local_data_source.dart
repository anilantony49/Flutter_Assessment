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
      version: 2, // Incremented version
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
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE tasks ADD COLUMN created_at TEXT');
      await db.execute('ALTER TABLE tasks ADD COLUMN updated_at TEXT');
    }
  }

  @override
  Future<List<TaskModel>> getTasks() async {
    final db = await database;
    final result = await db.query('tasks', orderBy: 'id DESC');
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
    await db.update(
      'tasks',
      task.toLocalMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
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
}
