import 'package:flutter/material.dart';
import '../database/task_dao.dart';
import '../model/task_model.dart';
import 'task_detail_screen.dart'; // Màn hình chi tiết công việc
import 'task_form_screen.dart'; // Màn hình thêm/sửa công việc
import 'package:thick/view/login_screen.dart';

class TaskListScreen extends StatefulWidget {
  final String currentUserId;
  final String currentUserRole;
  const TaskListScreen({
    super.key,
    required this.currentUserId,
    required this.currentUserRole,
  });

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<TaskModel> tasks = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final taskDao = TaskDao();
    final allTasks = await taskDao.getAllTasksForUser(
      widget.currentUserId,
      widget.currentUserRole,
    );
    setState(() {
      tasks = allTasks;
    });
  }



  void _navigateToCreateTaskScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskFormScreen(
          currentUserId: widget.currentUserId,
          currentUserRole: widget.currentUserRole,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Danh sách công việc'),
          actions: [
      IconButton(
      icon: const Icon(Icons.logout),
      onPressed: () {
        // Đăng xuất: Quay về màn hình đăng nhập
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      },
    ),
    ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Tìm kiếm công việc...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),

            ),
            const SizedBox(height: 10),
            Expanded(
              child: tasks.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return ListTile(
                    title: Text(task.title),
                    subtitle: Text(task.status),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TaskFormScreen(
                                  currentUserId: widget.currentUserId,
                                  currentUserRole: widget.currentUserRole,
                                  existingTask: task, // 👈 Truyền task để chỉnh sửa
                                ),
                              ),
                            ).then((_) => _loadTasks());
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            try {
                              await TaskDao().deleteTask(
                                task.id,
                                widget.currentUserId,
                                widget.currentUserRole,
                              );
                              await _loadTasks(); // Refresh danh sách
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Đã xoá công việc')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Lỗi khi xoá: ${e.toString()}')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateTaskScreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}
