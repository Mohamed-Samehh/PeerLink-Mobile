import 'dart:io';
import '../api/api_client.dart';
import '../api/endpoints.dart';
import '../models/user.dart';
import '../models/api_response.dart';

class UserRepository {
  final ApiClient _apiClient;

  UserRepository(this._apiClient);

  Future<ApiResponse<User>> getProfile() async {
    return await _apiClient.get<User>(
      Endpoints.profile,
      fromJson: (json) => User.fromJson(json),
    );
  }

  Future<ApiResponse<User>> updateProfile({
    String? name,
    String? username,
    String? email,
    String? phoneNum,
    String? dob,
    String? gender,
    String? bio,
    File? profilePicture,
  }) async {
    final fields = <String, String>{};

    if (name != null) fields['name'] = name;
    if (username != null) fields['username'] = username;
    if (email != null) fields['email'] = email;
    if (phoneNum != null) fields['phone_num'] = phoneNum;
    if (dob != null) fields['dob'] = dob;
    if (gender != null) fields['gender'] = gender;
    if (bio != null) fields['bio'] = bio;

    final files =
        profilePicture != null ? {'profile_picture': profilePicture} : null;

    return await _apiClient.put<User>(
      Endpoints.profile,
      fields: fields,
      files: files,
      fromJson: (json) => User.fromJson(json),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> updatePassword({
    required String password,
    required String passwordConfirmation,
  }) async {
    return await _apiClient.put<Map<String, dynamic>>(
      Endpoints.updatePassword,
      data: {
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }

  Future<ApiResponse<List<User>>> searchUsers(String query) async {
    return await _apiClient.get<List<User>>(
      Endpoints.search,
      queryParams: {'search': query},
      fromJson:
          (json) =>
              (json['data'] as List)
                  .map((item) => User.fromJson(item))
                  .toList(),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> toggleFollow(int userId) async {
    return await _apiClient.post<Map<String, dynamic>>(
      Endpoints.follow + userId.toString(),
    );
  }
}
