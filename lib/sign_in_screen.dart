import 'package:flutter/material.dart';
import 'package:todolist/home.dart'; // Import màn hình Home
import 'package:todolist/sign_up_screen.dart'; // Import màn hình đăng ký
import 'package:todolist/database/database_helper.dart';
import 'package:todolist/database/user.dart';

/// Màn hình đăng nhập cho ứng dụng
class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

/// State của SignInScreen quản lý quá trình đăng nhập
class _SignInScreenState extends State<SignInScreen> {
  // Controller cho các TextField nhập email và mật khẩu
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isObscure = true; // Kiểm soát hiển thị mật khẩu (ẩn/hiện)
  int? _userId; // Lưu trữ userId khi đăng nhập thành công

  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar hiển thị tiêu đề của ứng dụng
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
                child: Image.network(
                  'https://static.wikia.nocookie.net/violet-evergarden/images/a/ae/Violet_Evergarden.png/revision/latest?cb=20180209195829',
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 15),
              // Form nhập thông tin đăng nhập
              Container(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
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
                        decoration: const InputDecoration(
                          labelText: 'Tên đăng nhập',
                          border: OutlineInputBorder(),
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
                          // Nút để chuyển đổi trạng thái ẩn/hiện mật khẩu
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
                    // Liên kết chuyển sang màn hình đăng ký nếu người dùng chưa có tài khoản
                    ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          const Text(
                            'Bạn chưa có tài khoản ?',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SignUpScreen()),
                              );
                            },
                            child: const Text(
                              'Đăng ký',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              // Nút đăng nhập với xử lý logic xác thực và điều hướng
              ElevatedButton(
                onPressed: () async {
                  // Kiểm tra xem trường email và mật khẩu có trống không
                  if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Vui lòng nhập tên đăng nhập và mật khẩu')),
                    );
                  } else {
                    // Gọi hàm kiểm tra đăng nhập từ cơ sở dữ liệu
                    bool isLoggedIn = await dbHelper.checkLogin(
                      _emailController.text,
                      _passwordController.text,
                    );

                    if (isLoggedIn) {
                      // Nếu đăng nhập thành công, lấy userId từ cơ sở dữ liệu
                      _userId = await dbHelper.getUserIdByEmail(_emailController.text);
                      if (_userId != null) {
                        // Điều hướng sang màn hình Home nếu userId tồn tại
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Home(userId: _userId!, email: _emailController.text,)),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Không tìm thấy user_id cho email này')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Tài khoản mật khẩu không đúng hoặc không tồn tại')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(),
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: const Text(
                  'Đăng nhập',
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
