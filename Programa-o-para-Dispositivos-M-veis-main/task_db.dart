import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TaskDb {
  static final TaskDb instance = TaskDb._init();
  static Database? _database;

  TaskDb._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'task_db.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );

    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task TEXT NOT NULL,
        done INTEGER NOT NULL,
        created TEXT NOT NULL
      )
    ''');
  }

  // CREATE
  Future<int> insertTask(String task) async {
    final db = await database;

    return await db.insert(
      'tasks',
      {
        'task': task,
        'done': 0,
        'created': DateTime.now().toIso8601String(),
      },
    );
  }

  // READ - Todas as tarefas
  Future<List<Map<String, dynamic>>> getTasks() async {
    final db = await database;

    return await db.query(
      'tasks',
      orderBy: 'id DESC',
    );
  }

  // READ - Buscar por ID
  Future<Map<String, dynamic>?> getTaskById(int id) async {
    final db = await database;

    final result = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  // UPDATE
  Future<int> updateTask({
    required int id,
    required String task,
    required int done,
  }) async {
    final db = await database;

    return await db.update(
      'tasks',
      {
        'task': task,
        'done': done,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Marcar como concluída
  Future<int> finishTask(int id) async {
    final db = await database;

    return await db.update(
      'tasks',
      {
        'done': 1,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE
  Future<int> deleteTask(int id) async {
    final db = await database;

    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE ALL
  Future<int> deleteAllTasks() async {
    final db = await database;

    return await db.delete('tasks');
  }

  // Fechar banco
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}