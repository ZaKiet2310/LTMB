import 'package:flutter/material.dart';
import '../database/task_dao.dart';
import '../database/user_dao.dart';
import '../model/task_model.dart';
import '../model/user_model.dart';
import 'task_list_screen.dart'; // Màn hình danh sách công việc

class TaskFormScreen extends StatefulWidget {
  final String currentUserId;
  final String currentUserRole;
  final TaskModel? existingTask;

  const TaskFormScreen({
    super.key,
    required this.currentUserId,
    required this.currentUserRole,
    this.existingTask, // Để sửa công việc
  });

  @override
  _TaskFormScreenState createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priorityController = TextEditingController();
  DateTime? _dueDate;
  String? _assignedTo;
  List<UserModel> _users = [];  // Danh sách người dùng

  @override
  void initState() {
    super.initState();
    _loadUsers(); // Tải danh sách người dùng
    if (widget.existingTask != null) {
      // Nếu chỉnh sửa công việc, điền thông tin vào form
      _titleController.text = widget.existingTask!.title;
      _descriptionController.text = widget.existingTask!.description;
      _priorityController.text = widget.existingTask!.priority.toString();
      _dueDate = widget.existingTask!.dueDate;
      _assignedTo = widget.existingTask!.assignedTo;
    } else {
      if (widget.currentUserRole != 'admin') {
        _assignedTo = widget.currentUserId; // Nếu không phải admin, tự gán công việc cho chính mình
      }
    }
  }

  Future<void> _loadUsers() async {
    // Lấy danh sách người dùng từ cơ sở dữ liệu
    final users = await UserDao().getAllUsers();
    setState(() {
      _users = users;
    });
  }

  Future<void> _pickDueDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _dueDate = pickedDate;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final newTask = TaskModel(
        id: widget.existingTask?.id ?? DateTime.now().toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        status: widget.existingTask?.status ?? 'To do',
        priority: int.parse(_priorityController.text),
        dueDate: _dueDate,
        createdAt: widget.existingTask?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        assignedTo: _assignedTo,
        createdBy: widget.existingTask?.createdBy ?? widget.currentUserId,
        category: widget.existingTask?.category,
        attachments: widget.existingTask?.attachments ?? [],
        completed: widget.existingTask?.completed ?? false,
      );


      if (widget.existingTask != null) {
        // Nếu có công việc đang chỉnh sửa, cập nhật công việc
        await TaskDao().updateTask(newTask, widget.currentUserRole, widget.currentUserId);
      } else {
        // Nếu là tạo mới công việc
        await TaskDao().insertTask(newTask, widget.currentUserRole, widget.currentUserId);
      }

      // Quay lại màn hình danh sách công việc sau khi lưu
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TaskListScreen(
            currentUserId: widget.currentUserId,
            currentUserRole: widget.currentUserRole,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.existingTask == null ? 'Thêm công việc' : 'Chỉnh sửa công việc')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Tiêu đề'),
                validator: (value) => value == null || value.isEmpty ? 'Không được để trống' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
                validator: (value) => value == null || value.isEmpty ? 'Không được để trống' : null,
              ),
              TextFormField(
                controller: _priorityController,
                decoration: const InputDecoration(labelText: 'Độ ưu tiên (1-3)'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || int.tryParse(value) == null || int.parse(value) < 1 || int.parse(value) > 3 ? 'Độ ưu tiên phải từ 1 đến 3' : null,
              ),
              const SizedBox(height: 10),
              // Dropdown chọn người dùng nếu là admin
              if (widget.currentUserRole == 'admin') ...[
                DropdownButtonFormField<String>(
                  value: _assignedTo,
                  decoration: const InputDecoration(labelText: 'Gán công việc cho'),
                  items: _users.map((user) {
                    return DropdownMenuItem<String>(
                      value: user.id,
                      child: Text(user.username),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _assignedTo = value;
                    });
                  },
                  validator: (value) => value == null ? 'Vui lòng chọn người được giao công việc' : null,
                ),
              ],
              const SizedBox(height: 10),
              TextButton(
                onPressed: _pickDueDate,
                child: Text(_dueDate == null ? 'Chọn ngày hết hạn' : 'Ngày hết hạn: ${_dueDate!.toLocal()}'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Lưu công việc'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
