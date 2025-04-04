import 'package:flutter/material.dart';
import 'package:todolist/database/database_helper.dart';
import 'package:todolist/database/user.dart';
import 'package:intl/intl.dart';

/// Màn hình cập nhật thông tin tài khoản của người dùng
class UpdateAccountScreen extends StatefulWidget {
  final int userId;
  final String? email;
  const UpdateAccountScreen({Key? key, required this.userId, this.email}) : super(key: key);

  @override
  _UpdateAccountScreenState createState() => _UpdateAccountScreenState();
}

/// State của UpdateAccountScreen, quản lý việc lấy thông tin hiện tại và cập nhật tài khoản
class _UpdateAccountScreenState extends State<UpdateAccountScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isObscureOld = true;    // Kiểm soát ẩn/hiện mật khẩu hiện tại
  bool _isObscureNew = true;    // Kiểm soát ẩn/hiện mật khẩu mới
  bool _isObscureConfirm = true; // Kiểm soát ẩn/hiện xác nhận mật khẩu

  String currentUsername = ''; // Lưu tên đăng nhập hiện tại
  String? storedPassword;      // Lưu mật khẩu hiện tại từ cơ sở dữ liệu

  @override
  void initState() {
    super.initState();
    _loadUserInfo(); // Lấy thông tin người dùng khi khởi tạo màn hình
  }

  /// Lấy thông tin người dùng từ cơ sở dữ liệu dựa trên userId
  Future<void> _loadUserInfo() async {
    try {
      User? user = await dbHelper.getUserByUserId(widget.userId);
      if (user != null) {
        setState(() {
          currentUsername = user.username ?? '';
          _usernameController.text = user.username ?? '';
          storedPassword = user.password;
        });
      }
    } catch (e) {
      // Hiển thị thông báo lỗi nếu quá trình tải thông tin gặp sự cố
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user info: $e')),
      );
    }
  }

  /// Kiểm tra tính hợp lệ của form cập nhật: không để trống, mật khẩu mới phải khớp và mật khẩu hiện tại phải đúng
  bool _validateForm() {
    if (_usernameController.text.isEmpty ||
        _oldPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ')),
      );
      return false;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu mới và nhập lại không khớp')),
      );
      return false;
    }
    if (_oldPasswordController.text != storedPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu hiện tại không chính xác')),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Cập nhật tài khoản'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              const SizedBox(height: 15),
              // Hiển thị tên đăng nhập hiện tại của người dùng
              Text(
                'Tên đăng nhập hiện tại: $currentUsername',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              // TextField cập nhật tên người dùng
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Tên người dùng mới',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              // TextField nhập mật khẩu hiện tại với nút ẩn/hiện
              TextField(
                controller: _oldPasswordController,
                obscureText: _isObscureOld,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu hiện tại',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscureOld ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscureOld = !_isObscureOld;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // TextField nhập mật khẩu mới với nút ẩn/hiện
              TextField(
                controller: _newPasswordController,
                obscureText: _isObscureNew,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu mới',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscureNew ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscureNew = !_isObscureNew;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // TextField xác nhận mật khẩu mới với nút ẩn/hiện
              TextField(
                controller: _confirmPasswordController,
                obscureText: _isObscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Xác nhận mật khẩu mới',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscureConfirm ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscureConfirm = !_isObscureConfirm;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Nút "Cập nhật" xử lý cập nhật thông tin tài khoản khi form hợp lệ
              ElevatedButton(
                onPressed: () async {
                  if (_validateForm()) {
                    try {
                      User user = User(
                        userId: widget.userId,
                        email: widget.email,
                        username: _usernameController.text,
                        password: _newPasswordController.text,
                      );
                      await dbHelper.updateUser(user);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cập nhật thành công')),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Update failed: $e')),
                      );
                    }
                  }
                },
                child: const Text(
                  'Cập nhật',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(),
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
