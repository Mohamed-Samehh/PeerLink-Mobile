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
              (json['data'] as List? ?? [])
                  .map((item) => User.fromJson(item))
                  .toList(),
    );
  }

  Future<ApiResponse<List<User>>> getFollowing() async {
    final response = await _apiClient.get(Endpoints.following);

    if (response.success && response.data != null) {
      try {
        final List<dynamic> usersJson = response.data;
        final users = usersJson.map((json) => User.fromJson(json)).toList();
        return ApiResponse<List<User>>(success: true, data: users);
      } catch (e) {
        return ApiResponse<List<User>>(
          success: false,
          message: "Failed to parse user data",
        );
      }
    }

    return ApiResponse<List<User>>(
      success: response.success,
      message: response.message,
      errors: response.errors,
      data: [],
    );
  }

  Future<ApiResponse<List<User>>> getFollowers() async {
    final response = await _apiClient.get(Endpoints.followers);

    if (response.success && response.data != null) {
      try {
        final List<dynamic> usersJson = response.data;
        final users = usersJson.map((json) => User.fromJson(json)).toList();
        return ApiResponse<List<User>>(success: true, data: users);
      } catch (e) {
        return ApiResponse<List<User>>(
          success: false,
          message: "Failed to parse user data",
        );
      }
    }

    return ApiResponse<List<User>>(
      success: response.success,
      message: response.message,
      errors: response.errors,
      data: [],
    );
  }

  Future<ApiResponse<List<User>>> getFollowBack() async {
    final response = await _apiClient.get(Endpoints.followBack);

    if (response.success && response.data != null) {
      try {
        final List<dynamic> usersJson = response.data;
        final users = usersJson.map((json) => User.fromJson(json)).toList();
        return ApiResponse<List<User>>(success: true, data: users);
      } catch (e) {
        return ApiResponse<List<User>>(
          success: false,
          message: "Failed to parse user data",
        );
      }
    }

    return ApiResponse<List<User>>(
      success: response.success,
      message: response.message,
      errors: response.errors,
      data: [],
    );
  }

  Future<ApiResponse<List<User>>> getExplore() async {
    final response = await _apiClient.get(Endpoints.explore);

    if (response.success && response.data != null) {
      try {
        final List<dynamic> usersJson = response.data;
        final users = usersJson.map((json) => User.fromJson(json)).toList();
        return ApiResponse<List<User>>(success: true, data: users);
      } catch (e) {
        return ApiResponse<List<User>>(
          success: false,
          message: "Failed to parse user data",
        );
      }
    }

    return ApiResponse<List<User>>(
      success: response.success,
      message: response.message,
      errors: response.errors,
      data: [],
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> toggleFollow(int userId) async {
    return await _apiClient.post<Map<String, dynamic>>(
      Endpoints.follow + userId.toString(),
    );
  }
}
