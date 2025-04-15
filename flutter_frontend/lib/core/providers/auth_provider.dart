import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository;

  AuthStatus _status = AuthStatus.initial;
  AuthStatus get status => _status;

  User? _user;
  User? get user => _user;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Map<String, dynamic>? _validationErrors;
  Map<String, dynamic>? get validationErrors => _validationErrors;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AuthProvider(this._authRepository);

  Future<void> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String dob,
    required String gender,
    String? phoneNum,
    String? bio,
    required File profilePicture,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _validationErrors = null;
    notifyListeners();

    final response = await _authRepository.register(
      name: name,
      username: username,
      email: email,
      password: password,
      dob: dob,
      gender: gender,
      phoneNum: phoneNum,
      bio: bio,
      profilePicture: profilePicture,
    );

    if (response.success) {
      _user = User.fromJson(response.data!['user']);
      await _authRepository.saveToken(response.data!['token']);
      _status = AuthStatus.authenticated;
    } else {
      _errorMessage = response.message;
      _validationErrors = response.errors;
      _status = AuthStatus.unauthenticated;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _validationErrors = null;
    notifyListeners();

    final response = await _authRepository.login(
      username: username,
      password: password,
    );

    if (response.success) {
      _user = User.fromJson(response.data!['user']);
      await _authRepository.saveToken(response.data!['token']);
      _status = AuthStatus.authenticated;
    } else {
      _errorMessage = response.message;
      _validationErrors = response.errors;
      _status = AuthStatus.unauthenticated;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authRepository.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;

    _isLoading = false;
    notifyListeners();
  }

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void clearErrors() {
    _errorMessage = null;
    _validationErrors = null;
    notifyListeners();
  }
}
