import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE notes (
        id $idType,
        title $textType,
        content $textType,
        color $integerType,
        createdAt $textType,
        updatedAt $textType
      )
    ''');
  }

  // Create - Insert note
  Future<Note> create(Note note) async {
    final db = await instance.database;
    await db.insert('notes', note.toJson());
    return note;
  }

  // Read - Get single note
  Future<Note?> readNote(String id) async {
    final db = await instance.database;
    final maps = await db.query('notes', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Note.fromJson(maps.first);
    } else {
      return null;
    }
  }

  // Read - Get all notes
  Future<List<Note>> readAllNotes() async {
    final db = await instance.database;
    const orderBy = 'updatedAt DESC';
    final result = await db.query('notes', orderBy: orderBy);

    return result.map((json) => Note.fromJson(json)).toList();
  }

  // Update - Update note
  Future<int> update(Note note) async {
    final db = await instance.database;
    return db.update(
      'notes',
      note.toJson(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // Delete - Delete note
  Future<int> delete(String id) async {
    final db = await instance.database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // Delete all notes
  Future<int> deleteAll() async {
    final db = await instance.database;
    return await db.delete('notes');
  }

  // Close database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
