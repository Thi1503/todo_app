class Note {
  int? noteId;
  int userId;
  String title;
  String content;
  String? imagePath;
  bool isDone;
  bool isDeleted;
  DateTime? createdAt;
  DateTime? updatedAt;

  Note({
    this.noteId,
    required this.userId,
    required this.title,
    required this.content,
    this.imagePath,
    this.isDone = false,
    this.isDeleted = false,
    this.createdAt,
    this.updatedAt,
  });

  // Convert a Note object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'note_id': noteId,
      'user_id': userId,
      'title': title,
      'content': content,
      'is_done': isDone ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Extract a Note object from a Map object
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      noteId: map['note_id'],
      userId: map['user_id'],
      title: map['title'],
      content: map['content'],
      imagePath: map['image_path'],
      isDone: map['is_archived'] == 1,
      isDeleted: map['is_deleted'] == 1,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }
}
