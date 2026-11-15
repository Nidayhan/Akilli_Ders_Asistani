
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:bcrypt/bcrypt.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('akilli_ders_asistani.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Kullanıcı bilgileri
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Kullanıcı ve yapay zekâ arasındaki sohbet mesajları
    await db.execute('''
      CREATE TABLE chats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        message TEXT NOT NULL,
        sender TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Kullanıcının test sonuçları
    await db.execute('''
      CREATE TABLE test_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        score INTEGER NOT NULL,
        total_questions INTEGER NOT NULL,
        correct_answers INTEGER NOT NULL,
        wrong_answers INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }


  Future<int> registerUser({
    required String email,
    required String password,
  }) async {
    final db = await database;

    final passwordHash = BCrypt.hashpw(
      password,
      BCrypt.gensalt(),
    );

    return await db.insert('users', {
      'email': email.trim().toLowerCase(),
      'password_hash': passwordHash,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>?> loginUser({
    required String email,
    required String password,
  }) async {
    final db = await database;

    final results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    final user = results.first;
    final passwordHash = user['password_hash'] as String;

    if (BCrypt.checkpw(password, passwordHash)) {
      return user;
    }

    return null;
  }

  // Sohbet mesajını veritabanına kaydet
  Future<int> saveChat({
    required int userId,
    required String message,
    required String sender,
  }) async {
    final db = await database;

    return await db.insert('chats', {
      'user_id': userId,
      'message': message,
      'sender': sender,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Kullanıcının sohbet geçmişini getir
  Future<List<Map<String, dynamic>>> getChatHistory(
    int userId,
  ) async {
    final db = await database;

    return await db.query(
      'chats',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at ASC',
    );
  }


  Future<int> saveTestResult({
  required int userId,
  required int score,
  required int totalQuestions,
  required int correctAnswers,
  required int wrongAnswers,
}) async {
  final db = await database;

  return await db.insert('test_results', {
    'user_id': userId,
    'score': score,
    'total_questions': totalQuestions,
    'correct_answers': correctAnswers,
    'wrong_answers': wrongAnswers,
    'created_at': DateTime.now().toIso8601String(),
  });
}

}
