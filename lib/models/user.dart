import 'dart:convert';

/// Represents a user profile in the application.
class User {
  /// The unique identifier for the user.
  final int? id;

  /// The user's first name.
  final String firstName;

  /// The hashed representation of the user's access PIN.
  final String hashedPIN;

  /// Indicates if this is the user's first time using the application.
  final bool isFirstTime;

  /// Creates a [User] instance.
  User({
    this.id,
    required this.firstName,
    required this.hashedPIN,
    this.isFirstTime = true,
  });

  /// Converts the [User] instance into a [Map] for storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'hashed_pin': hashedPIN,
      'is_first_time': isFirstTime ? 1 : 0,
    };
  }

  /// Creates a [User] instance from a [Map].
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      firstName: map['first_name'] as String,
      hashedPIN: map['hashed_pin'] as String,
      isFirstTime: (map['is_first_time'] as int?) == 1,
    );
  }

  /// Verifies if a [rawPIN] matches the stored [hashedPIN].
  bool verifyPIN(String rawPIN) {
    return hashPIN(rawPIN) == hashedPIN;
  }

  /// Generates a base64 encoded hash of a raw PIN string.
  static String hashPIN(String rawPIN) {
    return base64Url.encode(utf8.encode(rawPIN));
  }
}