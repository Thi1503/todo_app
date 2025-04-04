import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'user.dart';
import 'note.dart';

/// Lớp DatabaseHelper để quản lý kết nối và thao tác với cơ sở dữ liệu SQLite
class DatabaseHelper {
  // Tạo một instance duy nhất của DatabaseHelper (Singleton pattern)
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  // Factory constructor trả về instance duy nhất
  factory DatabaseHelper() => _instance;
  // Biến lưu trữ đối tượng Database
  static Database? _database;

  // Constructor nội bộ, chỉ được gọi bên trong lớp
  DatabaseHelper._internal();

  /// Getter để lấy đối tượng Database, khởi tạo nếu chưa tồn tại
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Phương thức khởi tạo cơ sở dữ liệu
  Future<Database> _initDatabase() async {
    // Lấy đường dẫn thư mục lưu trữ cơ sở dữ liệu
    final databasePath = await getDatabasesPath();
    // Kết hợp đường dẫn với tên file cơ sở dữ liệu
    final path = join(databasePath, 'app_database.db');

    // Mở cơ sở dữ liệu, nếu chưa có sẽ tạo mới và gọi hàm _onCreate để khởi tạo bảng
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  /// Hàm tạo bảng trong cơ sở dữ liệu khi database được khởi tạo lần đầu
  Future<void> _onCreate(Database db, int version) async {
    // Tạo bảng User với các cột: user_id, username, email, password
    await db.execute('''
    CREATE TABLE User (
      user_id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      email TEXT NOT NULL,
      password TEXT NOT NULL
    )
  ''');

    // Tạo bảng Note với các cột: note_id, user_id, title, content, image_path, is_done, is_deleted, created_at, updated_at và định nghĩa khóa ngoại liên kết đến bảng User
    await db.execute('''
    CREATE TABLE Note (
      note_id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER,
      title TEXT NOT NULL,
      content TEXT NOT NULL,
      image_path TEXT,
      is_done BOOLEAN DEFAULT 0,
      is_deleted BOOLEAN DEFAULT 0,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES User(user_id)
    )
  ''');

    // In thông báo khi các bảng được tạo thành công
    print("Tables created successfully.");
  }

  // -------------------- Phương thức xử lý cho bảng User --------------------

  /// Chèn một người dùng mới vào bảng User
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('User', user.toMap());
  }

  /// Lấy danh sách tất cả người dùng từ bảng User
  Future<List<User>> getUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('User');
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  /// Cập nhật thông tin người dùng trong bảng User
  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'User',
      user.toMap(),
      where: 'user_id = ?',
      whereArgs: [user.userId],
    );
  }

  /// Xóa một người dùng khỏi bảng User dựa trên user_id
  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      'User',
      where: 'user_id = ?',
      whereArgs: [id],
    );
  }

  // -------------------- Phương thức xử lý cho bảng Note --------------------

  /// Chèn một ghi chú mới vào bảng Note
  Future<int> insertNote(Note note) async {
    final db = await database;
    return await db.insert('Note', note.toMap());
  }

  /// Lấy danh sách tất cả các ghi chú từ bảng Note
  Future<List<Note>> getNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Note');
    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  /// Lấy danh sách các ghi chú dựa trên user_id và có thể lọc theo từ khóa (keyword)
  Future<List<Map<String, dynamic>>> getNotesByUserId(int userId,
      {String? keyword}) async {
    final db = await database;
    List<Map<String, dynamic>> result;

    // Kiểm tra nếu keyword được cung cấp
    if (keyword == null || keyword.isEmpty) {
      // Nếu không có keyword, chỉ truy vấn theo user ID
      result = await db.query(
        'Note',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    } else {
      // Nếu có keyword, truy vấn theo user ID và keyword (so khớp với title hoặc content)
      result = await db.query(
        'Note',
        where: 'user_id = ? AND (title LIKE ? OR content LIKE ?)',
        whereArgs: [userId, '%$keyword%', '%$keyword%'],
      );
    }

    // In kết quả truy vấn để kiểm tra
    print('Query result: $result');
    return result;
  }

  /// Cập nhật thông tin của một ghi chú dựa trên user_id và note_id
  Future<void> updateNote(Note note) async {
    final db = await database;
    await db.update(
      'Note', // Sửa thành 'Note'
      note.toMap(),
      where:
          'user_id = ? AND note_id = ?', // Thay 'userId' thành 'user_id' và 'noteId' thành 'note_id'
      whereArgs: [note.userId, note.noteId],
    );
  }

  /// Xóa một ghi chú dựa trên user_id và note_id
  Future<void> deleteNote(int userId, int noteId) async {
    final db = await database;
    await db.delete(
      'Note',
      where: 'user_id = ? AND note_id = ?',
      whereArgs: [userId, noteId],
    );
  }

  /// Lấy user_id từ bảng User dựa trên email
  Future<int?> getUserIdByEmail(String email) async {
    try {
      final db = await database;
      List<Map<String, dynamic>> results = await db.query(
        'User',
        columns: ['user_id'], // Lấy cột user_id
        where: 'email = ?',
        whereArgs: [email],
      );
      if (results.isNotEmpty) {
        return results.first['user_id']; // Trả về user_id đầu tiên tìm được
      } else {
        return null; // Không tìm thấy email trong cơ sở dữ liệu
      }
    } catch (ex) {
      // In lỗi nếu có sự cố xảy ra
      print('Error: $ex');
      return null;
    }
  }

  /// Lấy username từ bảng User dựa trên user_id
  Future<String?> getUserNameByUserID(int userId) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'User',
      columns: ['username'],
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (results.isNotEmpty) {
      return results.first['username'] as String?;
    } else {
      return null; // Không tìm thấy user với user_id tương ứng
    }
  }

  /// Lấy đối tượng User từ bảng User dựa trên user_id
  Future<User?> getUserByUserId(int userId) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'User',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (results.isNotEmpty) {
      return User.fromMap(results.first);
    } else {
      return null; // Không tìm thấy user với user_id tương ứng
    }
  }

  /// Lấy giá trị lớn nhất của note_id trong bảng Note cho một user cụ thể
  Future<int?> getMaxNoteIdByUserId(int userId) async {
    try {
      final db = await database;
      List<Map<String, dynamic>> results = await db.rawQuery('''
        SELECT MAX(note_id) AS max_id FROM Note WHERE user_id = ?
      ''', [userId]);

      // Lấy giá trị note_id lớn nhất từ kết quả truy vấn
      int? maxId = results.first['max_id'];

      return maxId;
    } catch (ex) {
      // In lỗi nếu có sự cố xảy ra
      print('Error: $ex');
      return null;
    }
  }

  /// Kiểm tra thông tin đăng nhập của người dùng dựa trên username và password
  Future<bool> checkLogin(String username, String password) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'User', // Thay 'users' thành 'User' để khớp với tên bảng trong cơ sở dữ liệu
      where: 'email = ? AND password = ?',
      whereArgs: [username, password],
    );

    // Nếu truy vấn trả về kết quả không rỗng, trả về true
    return results.isNotEmpty;
  }

  /// Kiểm tra xem email đã tồn tại trong cơ sở dữ liệu chưa (dùng cho chức năng đăng ký)
  Future<bool> checkSignUp(String username) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'User',
      where: 'email = ?',
      whereArgs: [username],
    );
    // Nếu tồn tại bản ghi, trả về true
    return results.isNotEmpty;
  }
}
