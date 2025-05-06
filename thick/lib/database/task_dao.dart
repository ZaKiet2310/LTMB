import 'package:sqflite/sqflite.dart';
import '../model/task_model.dart';
import 'database_helper.dart';

class TaskDao {
  // ✅ Insert task: Admin có thể gán công việc cho bất kỳ người dùng nào,
  // còn người dùng thường chỉ gán công việc cho chính mình
  Future<void> insertTask(TaskModel task, String userRole ,String userId) async {
    if (userRole == 'admin' || task.assignedTo == userId) {
      final db = await DatabaseHelper.instance.database;
      await db.insert(
        'tasks',
        task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      throw Exception('Không có quyền gán công việc cho người khác');
    }
  }

  // ✅ Lấy danh sách công việc theo quyền người dùng
  Future<List<TaskModel>> getAllTasksForUser(String userId, String role) async {
    final db = await DatabaseHelper.instance.database;

    List<Map<String, dynamic>> result;

    if (role == 'admin') {
      result = await db.query('tasks'); // Admin lấy tất cả task
    } else {
      result = await db.query(
        'tasks',
        where: 'assignedTo = ?',
        whereArgs: [userId], // Người dùng lấy task được giao cho họ
      );
    }

    return result.map((map) => TaskModel.fromMap(map)).toList();
  }

  // ✅ Lấy công việc theo ID, kiểm tra quyền truy cập
  Future<TaskModel?> getTaskById(String taskId, String userId, String role) async {
    final db = await DatabaseHelper.instance.database;

    List<Map<String, dynamic>> result;

    if (role == 'admin') {
      result = await db.query(
        'tasks',
        where: 'id = ?',
        whereArgs: [taskId], // Admin có thể xem bất kỳ task nào
      );
    } else {
      result = await db.query(
        'tasks',
        where: 'id = ? AND assignedTo = ?',
        whereArgs: [taskId, userId], // Người dùng chỉ xem công việc của chính họ
      );
    }

    if (result.isNotEmpty) {
      return TaskModel.fromMap(result.first);
    } else {
      return null;
    }
  }


  // ✅ Cập nhật công việc, Admin có thể sửa công việc của bất kỳ ai, người dùng chỉ sửa công việc của mình
  Future<void> updateTask(TaskModel task, String userRole, String userId) async {
    if (userRole == 'admin' || task.assignedTo == userId) {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'tasks',
        task.toMap(),
        where: 'id = ?',
        whereArgs: [task.id],
      );
    } else {
      throw Exception('Bạn không có quyền sửa công việc của người khác');
    }
  }

  // ✅ Xóa công việc
  Future<void> deleteTask(String taskId, String userId, String role) async {
    final db = await DatabaseHelper.instance.database;

    if (role == 'admin') {
      await db.delete('tasks', where: 'id = ?', whereArgs: [taskId]);
    } else {
      // Cho phép người tạo hoặc người được giao xoá
      final deletedCount = await db.delete(
        'tasks',
        where: 'id = ? AND (createdBy = ? OR assignedTo = ?)',
        whereArgs: [taskId, userId, userId],
      );

      if (deletedCount == 0) {
        throw Exception('Bạn không có quyền xoá công việc này');
      }
    }
  }

}
