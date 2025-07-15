import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../screens/notes_screen.dart';

class NotesDatabaseHelper {
  static final NotesDatabaseHelper _instance = NotesDatabaseHelper._internal();
  factory NotesDatabaseHelper() => _instance;
  NotesDatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'notes_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes(
            id TEXT PRIMARY KEY,
            title TEXT,
            content TEXT,
            updatedAt TEXT,
            username TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertNote(Note note) async {
    final db = await database;
    await db.insert(
        'notes',
        {
          'id': note.id,
          'title': note.title,
          'content': note.content,
          'updatedAt': note.updatedAt.toIso8601String(),
          'username': note.username,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Note>> getNotes(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'username = ?',
      whereArgs: [username],
    );
    return List.generate(maps.length, (i) {
      return Note(
        id: maps[i]['id'],
        title: maps[i]['title'],
        content: maps[i]['content'],
        updatedAt: DateTime.parse(maps[i]['updatedAt']),
        username: maps[i]['username'],
      );
    });
  }

  Future<void> updateNote(Note note) async {
    final db = await database;
    await db.update(
      'notes',
      {
        'id': note.id,
        'title': note.title,
        'content': note.content,
        'updatedAt': note.updatedAt.toIso8601String(),
        'username': note.username,
      },
      where: 'id = ? AND username = ?',
      whereArgs: [note.id, note.username],
    );
  }

  Future<void> deleteNote(String id, String username) async {
    final db = await database;
    await db.delete(
      'notes',
      where: 'id = ? AND username = ?',
      whereArgs: [id, username],
    );
  }
}
