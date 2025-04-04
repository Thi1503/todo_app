import 'package:flutter/material.dart';
import 'notes_list_screen.dart';

/// Màn hình tìm kiếm ghi chú, cho phép người dùng nhập từ khóa để lọc danh sách ghi chú
class SearchScreen extends StatefulWidget {
  final int userId;

  SearchScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

/// State của SearchScreen, quản lý việc nhập và xử lý tìm kiếm
class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchController; // Controller cho TextField tìm kiếm
  bool showNotes = false; // Biến kiểm tra xem có hiển thị danh sách ghi chú hay không

  /// Khởi tạo state và thiết lập listener cho TextField tìm kiếm
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
  }

  /// Hủy controller khi không còn sử dụng để giải phóng tài nguyên
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Hàm xử lý khi nội dung tìm kiếm thay đổi, cập nhật trạng thái hiển thị danh sách ghi chú
  void _onSearchChanged() {
    setState(() {
      showNotes = _searchController.text.trim().isNotEmpty;
    });
  }

  /// Xây dựng giao diện của SearchScreen với AppBar chứa TextField tìm kiếm và hiển thị danh sách ghi chú nếu có từ khóa
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.only(right: 10, left: 10),
          child: TextField(
            controller: _searchController,
            style: TextStyle(fontSize: 20, color: Colors.black),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Tìm kiếm ghi chú',
              hintStyle: TextStyle(fontSize: 20, color: Colors.grey),
            ),
          ),
        ),
      ),
      // Hiển thị danh sách ghi chú nếu có từ khóa tìm kiếm, ngược lại hiển thị Container trống
      body: showNotes
          ? NotesListScreen(
        userId: widget.userId,
        searchKeyword: _searchController.text.trim(),
      )
          : Container(), // Không hiển thị ghi chú khi không có từ khóa tìm kiếm
    );
  }
}
