import 'dart:io';
import '../api/api_client.dart';
import '../api/endpoints.dart';
import '../models/user.dart';
import '../models/api_response.dart';

class UserRepository {
  final ApiClient _apiClient;

  UserRepository(this._apiClient);

  Future<ApiResponse<User>> getProfile() async {
    final response = await _apiClient.get(Endpoints.profile);

    if (response.success && response.data != null) {
      try {
        final user = User.fromJson(response.data);
        return ApiResponse<User>(success: true, data: user);
      } catch (e) {
        return ApiResponse<User>(
          success: false,
          message: "Failed to parse profile data",
        );
      }
    }

    return ApiResponse<User>(
      success: response.success,
      message: response.message,
      errors: response.errors,
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
    bool removeProfilePicture = false,
  }) async {
    final fields = <String, String>{};

    if (name != null) fields['name'] = name;
    if (username != null) fields['username'] = username;
    if (email != null) fields['email'] = email;
    if (phoneNum != null) fields['phone_num'] = phoneNum;
    if (dob != null) fields['dob'] = dob;
    if (gender != null) fields['gender'] = gender;
    if (bio != null) fields['bio'] = bio;
    if (removeProfilePicture) fields['remove_profile_picture'] = 'true';

    final files =
        (profilePicture != null && !removeProfilePicture)
            ? {'profile_picture': profilePicture}
            : null;

    final response = await _apiClient.put(
      Endpoints.profile,
      fields: fields,
      files: files,
    );

    if (response.success && response.data != null) {
      try {
        final user = User.fromJson(response.data);
        return ApiResponse<User>(success: true, data: user);
      } catch (e) {
        return ApiResponse<User>(
          success: false,
          message: "Failed to parse updated profile data",
        );
      }
    }

    return ApiResponse<User>(
      success: response.success,
      message: response.message,
      errors: response.errors,
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

  Future<ApiResponse<User>> getUserProfile(int userId) async {
    final response = await _apiClient.get(
      Endpoints.userProfile + userId.toString(),
    );

    if (response.success && response.data != null) {
      try {
        final user = User.fromJson(response.data);
        return ApiResponse<User>(success: true, data: user);
      } catch (e) {
        return ApiResponse<User>(
          success: false,
          message: "Failed to parse user profile data",
        );
      }
    }

    return ApiResponse<User>(
      success: response.success,
      message: response.message,
      errors: response.errors,
    );
  }

  Future<ApiResponse<List<User>>> searchUsers(String query) async {
    final response = await _apiClient.get(
      Endpoints.search,
      queryParams: {'search': query},
    );

    if (response.success && response.data != null) {
      try {
        final List<dynamic> usersJson = response.data;
        final users = usersJson.map((item) => User.fromJson(item)).toList();
        return ApiResponse<List<User>>(success: true, data: users);
      } catch (e) {
        return ApiResponse<List<User>>(
          success: false,
          message: "Failed to parse search results",
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

  Future<ApiResponse<List<User>>> getFollowing() async {
    final response = await _apiClient.get(Endpoints.following);

    if (response.success && response.data != null) {
      try {
        final List<dynamic> usersJson = response.data;
        final users = usersJson.map((item) => User.fromJson(item)).toList();
        return ApiResponse<List<User>>(success: true, data: users);
      } catch (e) {
        return ApiResponse<List<User>>(
          success: false,
          message: "Failed to parse following data",
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
        final users = usersJson.map((item) => User.fromJson(item)).toList();
        return ApiResponse<List<User>>(success: true, data: users);
      } catch (e) {
        return ApiResponse<List<User>>(
          success: false,
          message: "Failed to parse followers data",
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
        final users = usersJson.map((item) => User.fromJson(item)).toList();
        return ApiResponse<List<User>>(success: true, data: users);
      } catch (e) {
        return ApiResponse<List<User>>(
          success: false,
          message: "Failed to parse follow back data",
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
        final users = usersJson.map((item) => User.fromJson(item)).toList();
        return ApiResponse<List<User>>(success: true, data: users);
      } catch (e) {
        return ApiResponse<List<User>>(
          success: false,
          message: "Failed to parse explore data",
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
