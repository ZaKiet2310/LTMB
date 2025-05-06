import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../database/user_dao.dart';
import '../model/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();

  // Thêm biến để lưu lựa chọn role
  String _selectedRole = 'user'; // Mặc định là 'user'

  // Hàm đăng ký
  void _submitRegister() async {
    if (_formKey.currentState!.validate()) {
      final id = const Uuid().v4();
      final newUser = UserModel(
        id: id,
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        email: _emailController.text.trim(),
        avatar: null,
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
        role: _selectedRole, // Lưu role người dùng chọn
      );

      final dao = UserDao();
      await dao.insertUser(newUser); // Kết nối với SQLite
      if (mounted) {
        Navigator.pop(context); // Quay lại màn hình đăng nhập
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký tài khoản')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Tên đăng nhập'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Không được để trống' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                value == null || !value.contains('@') ? 'Email không hợp lệ' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Mật khẩu'),
                obscureText: true,
                validator: (value) =>
                value == null || value.length < 6 ? 'Ít nhất 6 ký tự' : null,
              ),
              const SizedBox(height: 20),

              // DropdownButton để chọn role
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'Chọn quyền'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRole = newValue!;
                  });
                },
                items: const [
                  DropdownMenuItem(
                    value: 'user',
                    child: Text('User'),
                  ),
                  DropdownMenuItem(
                    value: 'admin',
                    child: Text('Admin'),
                  ),
                ],
                validator: (value) => value == null ? 'Vui lòng chọn quyền' : null,
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitRegister,
                child: const Text('Đăng ký'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
