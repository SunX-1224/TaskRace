import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'user_data.dart';

const String databaseName = 'taskrace.db';
const String table = 'tasks';

class DBManager {
  static final DBManager instance = DBManager._init();
  static Database? _database;

  DBManager._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB(databaseName);
    return _database!;
  }

  Future<Database> _initDB(String filename) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filename);
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) => _createDB(db, version),
    );
  }

  Future _createDB(Database db, int version) async {
    const textType = 'TEXT';
    const intType = 'INTEGER';
    db.execute(
        'CREATE TABLE $table(${TaskFields.id} $intType, ${TaskFields.title} $textType, ${TaskFields.description} $textType, ${TaskFields.priority} $intType, ${TaskFields.status} $intType, ${TaskFields.isDeadline} $intType, ${TaskFields.time} $textType, ${TaskFields.interval} $textType)');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future inserttask(Task task) async {
    final db = await instance.database;
    await db.insert(table, task.toJson());
  }

  Future<List<Task>> getTasks() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(table);
    return maps.map((json) => Task.fromJson(json)).toList();
  }

  Future<int> updateTask(Task task) async {
    final db = await instance.database;
    return await db.update(table, task.toJson(),
        where: '${TaskFields.id} = ?', whereArgs: [task.id]);
  }

  Future deleteTask(Task task) async {
    final db = await instance.database;
    await db.delete(table, where: '${TaskFields.id} = ?', whereArgs: [task.id]);
  }

  Future<void> storeInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, value);
  }

  Future<int> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key) ?? 0;
  }
}
