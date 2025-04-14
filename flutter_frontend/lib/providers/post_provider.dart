import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/like.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Post> _posts = [];
  String? _error;

  List<Post> get posts => _posts;
  String? get error => _error;

  Future<void> fetchPosts() async {
    try {
      final token = await _getToken();
      final response = await _apiService.get('/posts', token);
      _posts =
          (jsonDecode(response.body) as List)
              .map((data) => Post.fromJson(data))
              .toList();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> createPost(String content, File? image) async {
    try {
      final token = await _getToken();
      final response = await _apiService.postMultipart(
        '/posts',
        {'content': content},
        image,
        token,
      );
      _posts.insert(0, Post.fromJson(jsonDecode(response.body)));
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePost(int postId) async {
    try {
      final token = await _getToken();
      await _apiService.delete('/posts/$postId', token);
      _posts.removeWhere((post) => post.id == postId);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleLike(int postId) async {
    try {
      final token = await _getToken();
      final response = await _apiService.post('/like/$postId', {}, token);
      final status = jsonDecode(response.body)['status'] ?? '';
      final postIndex = _posts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        _posts[postIndex] = Post(
          id: post.id,
          userId: post.userId,
          content: post.content,
          imageUrl: post.imageUrl,
          createdAt: post.createdAt,
          user: post.user,
          likeCount: post.likeCount + (status == 'liked' ? 1 : -1),
          userLiked: status == 'liked',
        );
      }
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<List<Like>> fetchLikes(int postId) async {
    try {
      final token = await _getToken();
      final response = await _apiService.get('/likes/$postId', token);
      return (jsonDecode(response.body) as List)
          .map((data) => Like.fromJson(data))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}
