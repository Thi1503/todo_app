import 'package:todolist/add_screen.dart';
import 'package:todolist/database/database_helper.dart';
import 'package:flutter/material.dart';

import 'note_widget.dart';

/// Màn hình hiển thị danh sách ghi chú của người dùng, có hỗ trợ tìm kiếm và chế độ lựa chọn
class NotesListScreen extends StatefulWidget {
  final int userId;
  final String? searchKeyword;

  const NotesListScreen({
    Key? key,
    required this.userId,
    this.searchKeyword,
  }) : super(key: key);

  @override
  _NotesListScreenState createState() => _NotesListScreenState();
}

/// State của NotesListScreen, chịu trách nhiệm lấy và hiển thị danh sách ghi chú
class _NotesListScreenState extends State<NotesListScreen> {
  // Future chứa danh sách ghi chú lấy từ cơ sở dữ liệu
  late Future<List<Map<String, dynamic>>> _notesFuture;
  // Biến kiểm tra chế độ lựa chọn (choice mode)
  bool isChoiceMode = false;

  @override
  void initState() {
    super.initState();
    // Tải danh sách ghi chú khi khởi tạo màn hình
    refreshNotes();
  }

  /// Hàm refreshNotes cập nhật danh sách ghi chú từ cơ sở dữ liệu theo userId và từ khóa tìm kiếm (nếu có)
  void refreshNotes() {
    setState(() {
      _notesFuture = DatabaseHelper()
          .getNotesByUserId(widget.userId, keyword: widget.searchKeyword);
    });
  }

  /// Hàm toggleChoiceMode chuyển đổi giữa chế độ lựa chọn và chế độ xem thông thường
  void toggleChoiceMode() {
    setState(() {
      isChoiceMode = !isChoiceMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Hiển thị AppBar nếu đang ở chế độ lựa chọn
      appBar: isChoiceMode ? _buildChoiceAppBar() : null,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _notesFuture,
        builder: (context, snapshot) {
          // Hiển thị loading khi dữ liệu đang được tải
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          // Hiển thị lỗi nếu có lỗi xảy ra khi lấy dữ liệu
          else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // Hiển thị thông báo nếu không có ghi chú nào
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No notes available'));
          }
          else {
            final notes = snapshot.data!;
            // Hiển thị danh sách ghi chú theo dạng ListView
            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return NoteWidget(
                  noteId: note['note_id'],
                  userId: note['user_id'],
                  title: note['title'],
                  content: note['content'],
                  imagePath: note['image_path'],
                  // Kiểm tra trạng thái ghi chú (done hoặc chưa done)
                  isDone: note['is_done'] == 1,
                  isDeleted: note['is_deleted'] == 1,
                  createdAt: DateTime.parse(note['created_at']),
                  updatedAt: DateTime.parse(note['updated_at']),
                  isChoiceMode: isChoiceMode,
                  toggleChoiceMode: toggleChoiceMode,
                  onUpdate: refreshNotes, // Refresh lại danh sách sau khi cập nhật
                );
              },
            );
          }
        },
      ),
    );
  }

  /// Hàm xây dựng AppBar khi đang ở chế độ lựa chọn, cho phép thoát chế độ lựa chọn
  AppBar _buildChoiceAppBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          setState(() {
            isChoiceMode = false;
          });
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              isChoiceMode = false;
            });
          },
          child: const Text(
            'Xong',
            style: TextStyle(fontSize: 20, color: Colors.blue),
          ),
        )
      ],
    );
  }
}
