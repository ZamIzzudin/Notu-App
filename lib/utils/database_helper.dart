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
    const imageType = 'TEXT';
    const integerType = 'INTEGER NOT NULL';
    const boolType = 'INTEGER NOT NULL DEFAULT 0';

    await db.execute('''
      CREATE TABLE notes (
        id $idType,
        title $textType,
        content $textType,
        isPinned $boolType,
        imagePath $imageType,
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
    final result = await db.query(
      'notes',
      orderBy: 'isPinned DESC, updatedAt DESC',
    );
    return result.map((json) => Note.fromJson(json)).toList();
  }

  // Get pinned note
  Future<Note?> getPinnedNote() async {
    final db = await database;
    final result = await db.query(
      'notes',
      where: 'isPinned = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return Note.fromJson(result.first);
    }
    return null;
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

  // Pin/Unpin note - Fixed version
  Future<void> togglePinNote(String noteId) async {
    final db = await database;

    // Get current note
    final currentNote = await readNote(noteId);
    if (currentNote == null) return;

    if (currentNote.isPinned) {
      // If already pinned, unpin it
      await db.update(
        'notes',
        {'isPinned': 0},
        where: 'id = ?',
        whereArgs: [noteId],
      );
    } else {
      // If not pinned, unpin all others first, then pin this one
      await db.update('notes', {'isPinned': 0});
      await db.update(
        'notes',
        {'isPinned': 1},
        where: 'id = ?',
        whereArgs: [noteId],
      );
    }
  }

  // Unpin note
  Future<void> unpinNote(String noteId) async {
    final db = await database;
    await db.update(
      'notes',
      {'isPinned': 0},
      where: 'id = ?',
      whereArgs: [noteId],
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

  // Force reset database (untuk development/testing)
  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'notes.db');

    if (_database != null) {
      await _database!.close();
      _database = null;
    }

    await deleteDatabase(path);
    _database = await _initDB('notes.db');
  }
}
