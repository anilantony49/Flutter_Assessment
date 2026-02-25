import 'package:flutter_assesment/data/models/task_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getTasks();
  Future<void> cacheTasks(List<TaskModel> tasks);
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
      version: 1,
      onCreate: _createDB,
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
        due_date TEXT
      )
    ''');
  }

  @override
  Future<List<TaskModel>> getTasks() async {
    final db = await database;
    final result = await db.query('tasks');
    return result.map((json) => TaskModel.fromLocalMap(json)).toList();
  }

  @override
  Future<void> cacheTasks(List<TaskModel> tasks) async {
    final db = await database;
    final batch = db.batch();
    batch.delete('tasks');
    for (var task in tasks) {
      batch.insert('tasks', task.toLocalMap());
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> clearCache() async {
    final db = await database;
    await db.delete('tasks');
  }
}
