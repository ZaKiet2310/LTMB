import 'package:flutter/material.dart';
import '../database/task_dao.dart';
import '../model/task_model.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;
  final String currentUserId;
  final String currentUserRole;

  const TaskDetailScreen({
    super.key,
    required this.taskId,
    required this.currentUserId,
    required this.currentUserRole,
  });

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  TaskModel? task;

  @override
  void initState() {
    super.initState();
    _loadTaskDetail();
  }

  Future<void> _loadTaskDetail() async {
    final taskDao = TaskDao();
    final fetchedTask = await taskDao.getTaskById(
      widget.taskId,
      widget.currentUserId,
      widget.currentUserRole,
    );

    if (fetchedTask != null) {
      setState(() {
        task = fetchedTask;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết công việc')),
      body: task == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tiêu đề: ${task!.title}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Text('Mô tả: ${task!.description}'),
            const SizedBox(height: 10),
            Text('Trạng thái: ${task!.status}'),
            const SizedBox(height: 10),
            Text('Độ ưu tiên: ${task!.priority}'),
            const SizedBox(height: 10),
            Text('Ngày hết hạn: ${task!.dueDate?.toLocal()}'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Cập nhật trạng thái ở đây nếu cần
              },
              child: const Text('Cập nhật trạng thái'),
            ),
          ],
        ),
      ),
    );
  }
}
