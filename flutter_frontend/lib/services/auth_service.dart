import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<User> register({
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
    final response = await _apiService.postMultipart(
      '/register',
      {
        'name': name,
        'username': username,
        'email': email,
        'password': password,
        'dob': dob,
        'gender': gender,
        if (phoneNum != null) 'phone_num': phoneNum,
        if (bio != null) 'bio': bio,
      },
      profilePicture,
      null,
    );

    final data = jsonDecode(response.body);
    final user = User.fromJson(data['user']);
    await _saveToken(data['token']);
    return user;
  }

  Future<User> login(String username, String password) async {
    final response = await _apiService.post('/login', {
      'username': username,
      'password': password,
    }, null);

    final data = jsonDecode(response.body);
    final user = User.fromJson(data['user']);
    await _saveToken(data['token']);
    return user;
  }

  Future<void> logout() async {
    final token = await _getToken();
    await _apiService.post('/logout', {}, token);
    await _clearToken();
  }

  Future<User> getProfile() async {
    final token = await _getToken();
    final response = await _apiService.get('/profile', token);
    return User.fromJson(jsonDecode(response.body));
  }

  Future<User> updateProfile({
    required String name,
    required String username,
    required String email,
    String? phoneNum,
    String? dob,
    String? gender,
    String? bio,
    File? profilePicture,
  }) async {
    final token = await _getToken();
    final response = await _apiService.putMultipart(
      '/profile',
      {
        'name': name,
        'username': username,
        'email': email,
        if (phoneNum != null) 'phone_num': phoneNum,
        if (dob != null) 'dob': dob,
        if (gender != null) 'gender': gender,
        if (bio != null) 'bio': bio,
      },
      profilePicture,
      token,
    );

    return User.fromJson(jsonDecode(response.body));
  }

  Future<void> updatePassword(String password) async {
    final token = await _getToken();
    await _apiService.put('/password', {'password': password}, token);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}
