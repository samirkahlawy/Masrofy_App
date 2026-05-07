import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'dart:developer' as developer;

import '../data/repositories/i_finance_repository.dart';
import '../data/repositories/sqlite_finance_repository.dart';
import '../models/user.dart';

/// Manages user authentication state, PIN verification, and user profile persistence.
class AuthProvider extends ChangeNotifier {
  final IFinanceRepository _repo;
  User? _currentUser;

  /// Creates an [AuthProvider]. Optionally accepts a custom [IFinanceRepository].
  AuthProvider({IFinanceRepository? repo})
    : _repo = repo ?? SqliteFinanceRepository();

  /// Returns the currently authenticated [User], or null if not logged in.
  User? get currentUser => _currentUser;

  /// Returns true if a user is currently authenticated.
  bool get isAuthenticated => _currentUser != null;

  /// Initializes the provider by fetching the stored user from the repository.
  Future<void> init() async {
    developer.log('AuthProvider: init called', name: 'AuthProvider');
    _currentUser = await _repo.getUser();
    developer.log(
      'AuthProvider: init - user=${_currentUser?.toMap()}',
      name: 'AuthProvider',
    );
    notifyListeners();
  }

  /// Verifies the provided [pin] against the stored user hash.
  /// 
  /// Returns `true` if authentication is successful and updates [currentUser].
  Future<bool> authenticate(String pin) async {
    developer.log(
      'AuthProvider: authenticate called with pin=$pin',
      name: 'AuthProvider',
    );
    final user = await _repo.getUser();
    developer.log('AuthProvider: user from repo=$user', name: 'AuthProvider');

    if (user == null) {
      developer.log(
        'AuthProvider: user is null, returning false',
        name: 'AuthProvider',
      );
      return false;
    }

    final isValid = user.verifyPIN(pin);
    developer.log('AuthProvider: isValid=$isValid', name: 'AuthProvider');

    if (isValid) {
      _currentUser = user;
      notifyListeners();
    }
    return isValid;
  }

  /// Creates or updates a user with a new [pin].
  Future<void> setPIN(String pin) async {
    developer.log(
      'AuthProvider: setPIN called with pin=$pin',
      name: 'AuthProvider',
    );
    final user = User(
      id: 1,
      firstName: 'User',
      hashedPIN: User.hashPIN(pin),
      isFirstTime: false,
    );
    await _repo.saveUser(user);
    _currentUser = user;
    notifyListeners();
  }

  /// Checks if a user has already set up a PIN in the system.
  Future<bool> hasSetupPIN() async {
    final user = await _repo.getUser();
    return user != null && user.hashedPIN.isNotEmpty;
  }

  /// Clears the current user session.
  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
  }

  /// Changes the user's PIN after verifying the [oldPIN].
  /// 
  /// Returns `false` if the [oldPIN] is incorrect or no user exists.
  Future<bool> changePIN(String oldPIN, String newPIN) async {
    developer.log('AuthProvider: changePIN called', name: 'AuthProvider');

    final user = await _repo.getUser();
    if (user == null || !user.verifyPIN(oldPIN)) {
      return false;
    }

    final newUser = User(
      id: user.id,
      firstName: user.firstName,
      hashedPIN: User.hashPIN(newPIN),
      isFirstTime: false,
    );

    await _repo.saveUser(newUser);
    _currentUser = newUser;
    notifyListeners();
    return true;
  }
}