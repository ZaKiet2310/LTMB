import 'package:flutter/material.dart';
import 'package:thick/database/user_dao.dart';
import 'package:thick/view/task_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _submitLogin() async {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      final user = await UserDao().getUserByUsernameAndPassword(username, password);

      if (user != null) {
        // Đăng nhập thành công → điều hướng sang màn hình chính
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TaskListScreen(
              currentUserId: user.id,
              currentUserRole: user.role,
            ),
          ),
        );
      } else {
        // Sai tài khoản hoặc mật khẩu
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Lỗi đăng nhập'),
            content: const Text('Tên đăng nhập hoặc mật khẩu không đúng.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _goToRegister() {
    Navigator.pushNamed(context, '/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
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
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Mật khẩu'),
                obscureText: true,
                validator: (value) =>
                value == null || value.length < 6 ? 'Ít nhất 6 ký tự' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitLogin,
                child: const Text('Đăng nhập'),
              ),
              TextButton(
                onPressed: _goToRegister,
                child: const Text('Chưa có tài khoản? Đăng ký'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
