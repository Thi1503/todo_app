class User {
  int? userId;
  String? username;
  String? email;
  String? password;


  User({
    this.userId,
    this.username,
    this.email,
    this.password,

  });

  // Convert a User object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'username': username,
      'email': email,
      'password': password,

    };
  }

  // Extract a User object from a Map object
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['user_id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],

    );
  }
}
