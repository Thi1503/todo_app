import 'package:todolist/add_screen.dart';
import 'package:todolist/update_screen.dart';
import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'notes_list_screen.dart';
import 'search_screen.dart';
import 'sign_in_screen.dart';

/// Màn hình chính hiển thị danh sách ghi chú và điều hướng đến các chức năng khác
class Home extends StatefulWidget {
  final int userId;
  final int? noteId;
  final String? email;

  const Home({
    Key? key,
    required this.userId,
    this.noteId,
    this.email,
  }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

/// State của Home, quản lý giao diện và dữ liệu người dùng
class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  bool isChoiceMode = false;
  String? userName;

  final DatabaseHelper dbHelper = DatabaseHelper();

  /// Khởi tạo state và load tên người dùng từ cơ sở dữ liệu
  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  /// Hàm lấy tên người dùng dựa trên userId và cập nhật state
  Future<void> _loadUserName() async {
    final fetchedUserName = await dbHelper.getUserNameByUserID(widget.userId);
    setState(() {
      userName = fetchedUserName;
    });
  }

  /// Xây dựng giao diện chính của màn hình Home
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),      // AppBar chứa thanh tìm kiếm
      drawer: _buildDrawer(context),       // Navigation drawer với các tùy chọn
      body: SafeArea(
        child: NotesListScreen(userId: widget.userId), // Danh sách ghi chú
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context), // Thanh công cụ dưới cùng
    );
  }

  /// Xây dựng AppBar với thanh tìm kiếm và avatar người dùng
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: ListTile(
        onTap: () {
          // Chuyển sang màn hình tìm kiếm ghi chú
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SearchScreen(
                  userId: widget.userId,
                )),
          );
        },
        title: const Text(
          'Tìm kiếm ghi chú',
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
        trailing: IconButton(
          onPressed: () {},
          iconSize: 40,
          icon: CircleAvatar(
            backgroundColor: Colors.transparent,
            child: ClipOval(
              child: Image.network(
                'https://static.wikia.nocookie.net/violet-evergarden/images/a/ae/Violet_Evergarden.png/revision/latest?cb=20180209195829',
                fit: BoxFit.cover,
                width: 40,
                height: 40,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Xây dựng Navigation Drawer với thông tin người dùng và các tùy chọn điều hướng
  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.transparent,
                child: ClipOval(
                  child: Image.asset(
                    'assets/violet.jpg',
                    fit: BoxFit.cover,
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
              // Hiển thị tên người dùng hoặc "Đang tải..." nếu chưa có
              title: Text(
                userName ?? 'Đang tải...',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.home,
                color: Colors.black,
              ),
              title: const Text('Home'),
              selected: _selectedIndex == 0,
              onTap: () {
                Navigator.pop(context); // Đóng drawer và quay lại Home
              },
            ),
            ListTile(
              leading: const Icon(Icons.add, color: Colors.black),
              title: const Text('Tạo ghi chú'),
              selected: _selectedIndex == 1,
              onTap: () {
                // Chuyển sang màn hình thêm ghi chú
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddScreen(userId: widget.userId)),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.settings,
                color: Colors.black,
              ),
              title: const Text('Cập nhật tài khoản'),
              selected: _selectedIndex == 2,
              onTap: () {
                // Chuyển sang màn hình cập nhật tài khoản
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UpdateAccountScreen(
                          userId: widget.userId, email: widget.email)),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.black,
              ),
              title: const Text('Đăng xuất'),
              onTap: () {
                // Chuyển sang màn hình đăng nhập
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignInScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Xây dựng Bottom Navigation Bar với các nút chức năng và FloatingActionButton
  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      elevation: 10,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.draw_outlined,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.mic_none,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Hiển thị hộp thoại chọn thêm hình ảnh
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Thêm hình ảnh'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.camera_alt_outlined),
                                title: const Text('Chụp ảnh'),
                                onTap: () {
                                  // Xử lý chụp ảnh
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.image_outlined),
                                title: const Text('Chọn từ thư viện'),
                                onTap: () {
                                  // Xử lý chọn ảnh từ thư viện
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  icon: const Icon(
                    Icons.image_outlined,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FloatingActionButton(
              onPressed: () {
                // Chuyển sang màn hình thêm ghi chú khi nhấn nút +
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddScreen(userId: widget.userId)),
                );
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.black,
                size: 40,
              ),
            ),
          )
        ],
      ),
    );
  }
}
