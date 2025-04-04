import 'package:flutter/material.dart';
import 'package:todolist/sign_in_screen.dart';
import 'package:todolist/database/database_helper.dart';
import 'package:todolist/database/user.dart';
import 'package:intl/intl.dart';

/// Màn hình đăng ký tài khoản cho người dùng
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

/// State của SignUpScreen, quản lý quá trình đăng ký tài khoản
class _SignUpScreenState extends State<SignUpScreen> {
  // Khởi tạo đối tượng DatabaseHelper để tương tác với cơ sở dữ liệu
  final DatabaseHelper dbHelper = DatabaseHelper();
  // Controllers cho các TextField nhập thông tin
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Biến điều khiển trạng thái ẩn/hiện mật khẩu cho 2 TextField
  bool _isObscure = true;
  bool _isObscure2 = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar hiển thị tiêu đề ứng dụng
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Ghi chú'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              const SizedBox(height: 15),
              // Hiển thị hình ảnh biểu tượng của ứng dụng
              Container(
                height: MediaQuery.of(context).size.height / 3,
                child: const Image(
                  image: AssetImage('assets/todolist.png'),
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 15),
              // Form nhập thông tin đăng ký
              Container(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    // TextField nhập tên người dùng
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _usernameController,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Tên người dùng',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // TextField nhập tên đăng nhập
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _emailController,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Tên đăng nhập',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // TextField nhập mật khẩu với chức năng ẩn/hiện mật khẩu
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _passwordController,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        obscureText: _isObscure,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscure ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscure = !_isObscure;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // TextField xác nhận lại mật khẩu với chức năng ẩn/hiện mật khẩu
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _confirmPasswordController,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        obscureText: _isObscure2,
                        decoration: InputDecoration(
                          labelText: 'Nhập lại mật khẩu',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscure2 ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscure2 = !_isObscure2;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Nút đăng ký xử lý logic đăng ký và điều hướng về màn hình đăng nhập
              ElevatedButton(
                onPressed: () async {
                  // Kiểm tra các trường thông tin đã được nhập đầy đủ chưa
                  if (_usernameController.text.isEmpty ||
                      _emailController.text.isEmpty ||
                      _passwordController.text.isEmpty ||
                      _confirmPasswordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
                    );
                  } else {
                    // Kiểm tra xem tên đăng nhập đã được sử dụng chưa
                    bool isRegistered = await dbHelper.checkSignUp(_emailController.text);
                    if (isRegistered) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tên đăng nhập đã được sử dụng')),
                      );
                    } else {
                      // Kiểm tra mật khẩu và xác nhận mật khẩu có khớp không
                      if (_passwordController.text == _confirmPasswordController.text) {
                        // Tạo đối tượng User từ thông tin đăng ký và lưu vào cơ sở dữ liệu
                        User user = User(
                          username: _usernameController.text,
                          email: _emailController.text,
                          password: _passwordController.text,
                        );
                        await dbHelper.insertUser(user);
                        // Điều hướng về màn hình đăng nhập sau khi đăng ký thành công
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignInScreen()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Mật khẩu không khớp')),
                        );
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(),
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text(
                  'Đăng ký',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
