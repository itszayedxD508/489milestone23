import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('lingovault.db');
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
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    await db.execute('''
CREATE TABLE users (
  id $idType,
  username $textType,
  total_xp $integerType DEFAULT 0
)
''');

    await db.execute('''
CREATE TABLE srs_cards (
  id $idType,
  user_id $integerType,
  word_id $integerType,
  ease_factor $realType DEFAULT 2.5,
  interval_days $integerType DEFAULT 1,
  repetitions $integerType DEFAULT 0,
  next_review_at $textType,
  FOREIGN KEY (user_id) REFERENCES users (id)
)
''');

    await db.execute('''
CREATE TABLE quiz_sessions (
  id $idType,
  user_id $integerType,
  session_type $textType,
  xp_earned $integerType DEFAULT 0,
  created_at $textType,
  FOREIGN KEY (user_id) REFERENCES users (id)
)
''');

    await db.execute('''
CREATE TABLE builder_attempts (
  id $idType,
  user_id $integerType,
  session_id $integerType,
  template_id $integerType,
  is_correct $boolType,
  created_at $textType,
  FOREIGN KEY (user_id) REFERENCES users (id),
  FOREIGN KEY (session_id) REFERENCES quiz_sessions (id)
)
''');

    await db.execute('''
CREATE TABLE translation_attempts (
  id $idType,
  user_id $integerType,
  session_id $integerType,
  template_id $integerType,
  match_score $realType,
  created_at $textType,
  FOREIGN KEY (user_id) REFERENCES users (id),
  FOREIGN KEY (session_id) REFERENCES quiz_sessions (id)
)
''');

    await db.execute('''
CREATE TABLE streak_tracking (
  id $idType,
  user_id $integerType,
  current_streak $integerType DEFAULT 0,
  longest_streak $integerType DEFAULT 0,
  last_activity_date $textType,
  FOREIGN KEY (user_id) REFERENCES users (id)
)
''');

    await db.execute('''
CREATE TABLE user_word_progress (
  id $idType,
  user_id $integerType,
  word_id $integerType,
  times_seen $integerType DEFAULT 0,
  times_correct $integerType DEFAULT 0,
  mastery_level $realType DEFAULT 0.0,
  FOREIGN KEY (user_id) REFERENCES users (id)
)
''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
