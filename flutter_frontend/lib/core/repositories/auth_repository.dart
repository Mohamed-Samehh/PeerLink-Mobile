import 'dart:io';
import '../api/api_client.dart';
import '../api/endpoints.dart';
import '../models/api_response.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<ApiResponse<Map<String, dynamic>>> register({
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
    final fields = {
      'name': name,
      'username': username,
      'email': email,
      'password': password,
      'dob': dob,
      'gender': gender,
      if (phoneNum != null) 'phone_num': phoneNum,
      if (bio != null) 'bio': bio,
    };

    final files = {'profile_picture': profilePicture};

    return await _apiClient.post<Map<String, dynamic>>(
      Endpoints.register,
      fields: fields,
      files: files,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> login({
    required String username,
    required String password,
  }) async {
    return await _apiClient.post<Map<String, dynamic>>(
      Endpoints.login,
      data: {'username': username, 'password': password},
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> logout() async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      Endpoints.logout,
    );
    if (response.success) {
      await _apiClient.clearToken();
    }
    return response;
  }

  Future<void> saveToken(String token) async {
    await _apiClient.setToken(token);
  }
}
