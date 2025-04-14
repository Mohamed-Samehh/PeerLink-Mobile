import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  String? _error;

  User? get user => _user;
  String? get error => _error;

  Future<bool> register({
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
    try {
      _user = await _authService.register(
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
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      _user = await _authService.login(username, password);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _error = null;
    notifyListeners();
  }

  Future<void> fetchProfile() async {
    try {
      _user = await _authService.getProfile();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String username,
    required String email,
    String? phoneNum,
    String? dob,
    String? gender,
    String? bio,
    File? profilePicture,
  }) async {
    try {
      _user = await _authService.updateProfile(
        name: name,
        username: username,
        email: email,
        phoneNum: phoneNum,
        dob: dob,
        gender: gender,
        bio: bio,
        profilePicture: profilePicture,
      );
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePassword(String password) async {
    try {
      await _authService.updatePassword(password);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
