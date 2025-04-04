import 'package:flutter/material.dart';
import 'package:todolist/home.dart';
import 'package:todolist/database/database_helper.dart';
import 'package:todolist/database/note.dart';
import 'package:intl/intl.dart';

/// Màn hình thêm/chỉnh sửa ghi chú
class AddScreen extends StatefulWidget {
  final int? noteId;
  final int userId;
  final String? title;
  final String? content;
  final String? imagePath;
  final bool isDone;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AddScreen({
    Key? key,
    this.noteId,
    required this.userId,
    this.title,
    this.content,
    this.imagePath,
    this.isDone = false,
    this.isDeleted = false,
    this.createdAt,
    this.updatedAt,
  }) : super(key: key);

  @override
  _AddScreenState createState() => _AddScreenState();
}

/// State của màn hình AddScreen
class _AddScreenState extends State<AddScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  DateTime now = DateTime.now();

  int? maxNoteId;
  late bool isDoneState;

  /// Khởi tạo state, thiết lập controller và load maxNoteId
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _contentController = TextEditingController(text: widget.content);
    _loadMaxNoteId();
    isDoneState = widget.isDone;
  }

  /// Lấy giá trị noteId lớn nhất hiện có của user từ cơ sở dữ liệu
  Future<void> _loadMaxNoteId() async {
    maxNoteId = await dbHelper.getMaxNoteIdByUserId(widget.userId);
  }

  /// Định dạng thời gian theo định dạng dd/MM/yyyy HH:mm
  String formatDateTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(dateTime);
  }

  /// Xây dựng giao diện chính của màn hình
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context), // AppBar chứa nút lưu
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                maxLines: null,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Tiêu đề',
                  hintStyle: TextStyle(
                    fontSize: 24,
                    color: Colors.grey,
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _contentController,
                maxLines: null,
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Nội dung',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomAppBar(context), // Thanh công cụ dưới cùng
    );
  }

  /// Xây dựng AppBar với nút "Lưu" để lưu ghi chú
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          TextButton(
            onPressed: () async {
              String title = _titleController.text;
              String content = _contentController.text;

              if (widget.noteId != null) {
                // Chỉnh sửa ghi chú đã có
                Note note = Note(
                  userId: widget.userId,
                  noteId: widget.noteId,
                  title: title,
                  content: content,
                  isDone: isDoneState,
                  isDeleted: widget.isDeleted,
                  createdAt: widget.createdAt,
                  updatedAt: now, // Cập nhật thời gian chỉnh sửa mới
                );

                await dbHelper.updateNote(note);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Home(userId: widget.userId)),
                );
              } else {
                // Tạo ghi chú mới
                int? noteId;
                if (maxNoteId != null) {
                  noteId = maxNoteId! + 1;
                }

                Note note = Note(
                  userId: widget.userId,
                  noteId: noteId,
                  title: title,
                  content: content,
                  isDone: isDoneState,
                  isDeleted: false,
                  createdAt: now,
                  updatedAt: now,
                );

                await dbHelper.insertNote(note);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Home(userId: widget.userId)),
                );
              }
            },
            child: const Text(
              'Lưu',
              style: TextStyle(fontSize: 20, color: Colors.blue),
            ),
          )
        ],
      ),
    );
  }

  /// Xây dựng BottomAppBar với các chức năng: đánh dấu hoàn thành, thêm ảnh, hiển thị thời gian chỉnh sửa và xóa ghi chú
  BottomAppBar _buildBottomAppBar(BuildContext context) {
    String formattedDateTime = formatDateTime(now);

    return BottomAppBar(
      child: Row(
        children: [
          // Nút thay đổi trạng thái hoàn thành của ghi chú
          IconButton(
            onPressed: () {
              setState(() {
                isDoneState = !isDoneState;
              });
            },
            icon: Icon(
              isDoneState ? Icons.check_box : Icons.check_box_outline_blank,
              color: isDoneState ? Colors.green : Colors.black,
            ),
          ),
          Expanded(
            child: IconButton(
              onPressed: () {
                // Hiển thị hộp thoại để chọn thêm hình ảnh
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Thêm hình ảnh'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: Icon(Icons.camera_alt_outlined),
                            title: Text('Chụp ảnh'),
                            onTap: () {
                              // Xử lý chụp ảnh
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.image_outlined),
                            title: Text('Chọn từ thư viện'),
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
              icon: Icon(
                Icons.image_outlined,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                'Đã chỉnh sửa $formattedDateTime',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: IconButton(
              onPressed: () {
                // Hiển thị hộp thoại xác nhận xóa ghi chú
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Xác nhận xóa'),
                      content: const Text(
                          'Bạn có chắc chắn muốn xóa ghi chú này không?'),
                      actions: [
                        TextButton(
                          child: const Text('Huỷ'),
                          onPressed: () {
                            Navigator.of(context).pop(); // Đóng hộp thoại
                          },
                        ),
                        TextButton(
                          child: const Text('Xóa'),
                          onPressed: () async {
                            if (widget.noteId != null) {
                              // Xóa ghi chú nếu đang chỉnh sửa
                              await dbHelper.deleteNote(
                                  widget.userId, widget.noteId!);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Home(userId: widget.userId)),
                              );
                            }
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
