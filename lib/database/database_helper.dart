import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/todo.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'todo_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE todos(
            id TEXT PRIMARY KEY,
            todoText TEXT,
            isDone INTEGER,
            username TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertToDo(ToDo todo) async {
    final db = await database;
    await db.insert('todos', todo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ToDo>> getToDos(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'username = ?',
      whereArgs: [username],
    );
    return List.generate(maps.length, (i) {
      return ToDo.fromMap(maps[i]);
    });
  }

  Future<void> updateToDo(ToDo todo) async {
    final db = await database;
    await db.update(
      'todos',
      todo.toMap(),
      where: 'id = ? AND username = ?',
      whereArgs: [todo.id, todo.username],
    );
  }

  Future<void> deleteToDo(String id, String username) async {
    final db = await database;
    await db.delete(
      'todos',
      where: 'id = ? AND username = ?',
      whereArgs: [id, username],
    );
  }
}
