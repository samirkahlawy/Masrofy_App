class User {

  int? id;

  String firstName;

  String hashedPIN;

  bool isFirstTime;

  User({
    this.id,
    required this.firstName,
    required this.hashedPIN,
    required this.isFirstTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'hashedPIN': hashedPIN,
      'isFirstTime': isFirstTime,
    };
  }

  factory User.fromMap(
    Map<String, dynamic> map,
  ) {
    return User(
      id: map['id'],
      firstName: map['firstName'],
      hashedPIN: map['hashedPIN'],
      isFirstTime: map['isFirstTime'],
    );
  }

  bool verifyPIN(String rawPIN) {
    return hashedPIN == rawPIN;
  }

  String hashPIN(String rawPIN) {
    return rawPIN;
  }
}