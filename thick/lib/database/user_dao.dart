import 'package:sqflite/sqflite.dart';
import '../model/user_model.dart';
import 'database_helper.dart';

class UserDao {
  Future<void> insertUser(UserModel user) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<UserModel?> getUserByUsernameAndPassword(String username, String password) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<UserModel>> getAllUsers() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('users');
    return result.map((map) => UserModel.fromMap(map)).toList();
  }

  Future<void> updateUser(UserModel user) async {
    final db = await DatabaseHelper.instance.database;
    await db.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  Future<void> deleteTask(String taskId, String userId, String role) async {
    final db = await DatabaseHelper.instance.database;

    if (role == 'admin') {
      await db.delete('tasks', where: 'id = ?', whereArgs: [taskId]);
    } else {
      // Chỉ xoá nếu là người tạo task
      await db.delete('tasks', where: 'id = ? AND createdBy = ?', whereArgs: [taskId, userId]);
    }
  }
}
