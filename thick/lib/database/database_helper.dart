import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // Khai báo một instance duy nhất của DatabaseHelper
  static final DatabaseHelper instance = DatabaseHelper._init();

  // Biến _database để chứa cơ sở dữ liệu
  static Database? _database;

  // Khởi tạo private constructor
  DatabaseHelper._init();

  // Getter để truy cập database
  Future<Database> get database async {
    if (_database != null) return _database!;  // Nếu _database đã được khởi tạo, trả về nó
    _database = await _initDB('task_manager.db');  // Nếu chưa, khởi tạo mới
    return _database!;
  }

  // Hàm khởi tạo cơ sở dữ liệu
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();  // Lấy đường dẫn của cơ sở dữ liệu
    final path = join(dbPath, filePath);  // Tạo đường dẫn đầy đủ
    return await openDatabase(path, version: 1, onCreate: _createDB);  // Mở cơ sở dữ liệu
  }

  // Hàm tạo các bảng khi cơ sở dữ liệu chưa tồn tại
  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE users (
      id TEXT PRIMARY KEY,
      username TEXT NOT NULL,
      password TEXT NOT NULL,
      email TEXT,
      avatar TEXT,
      createdAt TEXT NOT NULL,
      lastActive TEXT NOT NULL,
      role TEXT NOT NULL
    );
    ''');

    await db.execute('''
    CREATE TABLE tasks (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      status TEXT NOT NULL,
      priority INTEGER NOT NULL,
      dueDate TEXT,
      createdAt TEXT NOT NULL,
      updatedAt TEXT NOT NULL,
      assignedTo TEXT,
      createdBy TEXT NOT NULL,
      category TEXT,
      attachments TEXT,
      completed INTEGER NOT NULL
    );
    ''');
  }

// Các phương thức CRUD cho User và Task sẽ được cài đặt ở đây...
}
