import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'dart:developer' as developer;

import '../data/repositories/i_finance_repository.dart';
import '../data/repositories/sqlite_finance_repository.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  final IFinanceRepository _repo;
  User? _currentUser;

  AuthProvider({IFinanceRepository? repo})
    : _repo = repo ?? SqliteFinanceRepository();

  User? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  Future<void> init() async {
    developer.log('AuthProvider: init called', name: 'AuthProvider');
    _currentUser = await _repo.getUser();
    developer.log(
      'AuthProvider: init - user=${_currentUser?.toMap()}',
      name: 'AuthProvider',
    );
    notifyListeners();
  }

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

    final hashedInput = User.hashPIN(pin);
    developer.log(
      'AuthProvider: hashedInput=$hashedInput, storedHash=${user.hashedPIN}',
      name: 'AuthProvider',
    );

    final isValid = user.verifyPIN(pin);
    developer.log('AuthProvider: isValid=$isValid', name: 'AuthProvider');

    if (isValid) {
      _currentUser = user;
      notifyListeners();
    }
    return isValid;
  }

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
    developer.log(
      'AuthProvider: saving user=${user.toMap()}',
      name: 'AuthProvider',
    );
    await _repo.saveUser(user);
    _currentUser = user;
    notifyListeners();
    developer.log(
      'AuthProvider: user saved successfully',
      name: 'AuthProvider',
    );
  }

  Future<bool> hasSetupPIN() async {
    final user = await _repo.getUser();
    return user != null && user.hashedPIN.isNotEmpty;
  }

  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> changePIN(String oldPIN, String newPIN) async {
    developer.log('AuthProvider: changePIN called', name: 'AuthProvider');

    final user = await _repo.getUser();
    if (user == null) {
      developer.log('AuthProvider: user is null', name: 'AuthProvider');
      return false;
    }

    // Verify old PIN
    if (!user.verifyPIN(oldPIN)) {
      developer.log('AuthProvider: old PIN incorrect', name: 'AuthProvider');
      return false;
    }

    // Create new user with new PIN
    final newUser = User(
      id: user.id,
      firstName: user.firstName,
      hashedPIN: User.hashPIN(newPIN),
      isFirstTime: false,
    );

    await _repo.saveUser(newUser);
    _currentUser = newUser;
    notifyListeners();

    developer.log(
      'AuthProvider: PIN changed successfully',
      name: 'AuthProvider',
    );
    return true;
  }
}
