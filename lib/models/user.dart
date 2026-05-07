import 'dart:convert';

class User {
  final int? id;
  final String firstName;
  final String hashedPIN;
  final bool isFirstTime;

  User({
    this.id,
    required this.firstName,
    required this.hashedPIN,
    this.isFirstTime = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'hashed_pin': hashedPIN,
      'is_first_time': isFirstTime ? 1 : 0,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      firstName: map['first_name'] as String,
      hashedPIN: map['hashed_pin'] as String,
      isFirstTime: (map['is_first_time'] as int?) == 1,
    );
  }

  bool verifyPIN(String rawPIN) {
    return hashPIN(rawPIN) == hashedPIN;
  }

  static String hashPIN(String rawPIN) {
    return base64Url.encode(utf8.encode(rawPIN));
  }
}
