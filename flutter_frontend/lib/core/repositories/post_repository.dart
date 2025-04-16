import 'dart:io';
import '../api/api_client.dart';
import '../api/endpoints.dart';
import '../models/post.dart';
import '../models/like.dart';
import '../models/api_response.dart';

class PostRepository {
  final ApiClient _apiClient;

  PostRepository(this._apiClient);

  Future<ApiResponse<List<Post>>> getPosts() async {
    return await _apiClient.get<List<Post>>(
      Endpoints.posts,
      fromJson:
          (json) =>
              (json['data'] as List? ?? [])
                  .map((item) => Post.fromJson(item))
                  .toList(),
    );
  }

  Future<ApiResponse<List<Post>>> getUserPosts() async {
    final response = await _apiClient.get(Endpoints.userPosts);

    if (response.success && response.data != null) {
      try {
        // Handle both array response and response with data property
        final List<dynamic> postsJson;
        if (response.data is List) {
          postsJson = response.data;
        } else if (response.data is Map && response.data.containsKey('data')) {
          postsJson = response.data['data'];
        } else {
          postsJson = [];
        }

        final posts = postsJson.map((json) => Post.fromJson(json)).toList();
        return ApiResponse<List<Post>>(success: true, data: posts);
      } catch (e) {
        return ApiResponse<List<Post>>(
          success: false,
          message: "Failed to parse post data",
        );
      }
    }

    return ApiResponse<List<Post>>(
      success: response.success,
      message: response.message,
      errors: response.errors,
      data: [],
    );
  }

  Future<ApiResponse<Post>> createPost({
    required String content,
    File? image,
  }) async {
    final fields = {'content': content};
    final files = image != null ? {'image': image} : null;

    return await _apiClient.post<Post>(
      Endpoints.posts,
      fields: fields,
      files: files,
      fromJson: (json) => Post.fromJson(json),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> deletePost(int postId) async {
    return await _apiClient.delete<Map<String, dynamic>>(
      Endpoints.post + postId.toString(),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> toggleLike(int postId) async {
    return await _apiClient.post<Map<String, dynamic>>(
      Endpoints.like + postId.toString(),
    );
  }

  Future<ApiResponse<List<Like>>> getLikes(int postId) async {
    return await _apiClient.get<List<Like>>(
      Endpoints.likes + postId.toString(),
      fromJson:
          (json) =>
              (json as List? ?? []).map((item) => Like.fromJson(item)).toList(),
    );
  }
}
