import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _db;
  
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB('masroufy.db');
    return _db!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE Category (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      icon TEXT,
      color TEXT,
      user_id INTEGER
    )
    ''');

    await db.execute('''
    CREATE TABLE Expense (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      amount REAL NOT NULL,
      note TEXT,
      date TEXT NOT NULL,
      categoryId INTEGER NOT NULL,
      FOREIGN KEY (categoryId) REFERENCES Category (id)
    )
    ''');

    await db.execute('''
    CREATE TABLE BudgetCycle (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      totalAllowance REAL NOT NULL,
      remainingBalance REAL NOT NULL,
      startDate TEXT NOT NULL,
      endDate TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE User (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      hashedPIN TEXT NOT NULL,
      isFirstTime INTEGER NOT NULL
    )
    ''');
  }
}