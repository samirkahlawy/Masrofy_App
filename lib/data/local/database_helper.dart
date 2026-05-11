/// A singleton helper class for managing database operations.
class DatabaseHelper {
  /// Private constructor for the singleton pattern.
  DatabaseHelper._internal();

  /// The single shared instance of [DatabaseHelper].
  static final DatabaseHelper instance = DatabaseHelper._internal();
}