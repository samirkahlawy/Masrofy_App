import '../repositories/ifinance_repository.dart';
import '../models/user.dart';

class AuthProvider {

  final IFinanceRepository _repo;

  User? _currentUser;

  AuthProvider(this._repo);

  User? get currentUser => _currentUser;

  bool get isAuthenticated =>
      _currentUser != null;

  Future<void> init() async {

  }

  Future<bool> authenticate(
    String pin,
  ) async {
    return true;
  }

  Future<void> setPIN(
    String pin,
  ) async {

  }

  Future<bool> hasSetupPIN() async {
    return false;
  }

  Future<void> logout() async {

  }

  Future<bool> changePIN(
    String oldPIN,
    String newPIN,
  ) async {
    return true;
  }
}