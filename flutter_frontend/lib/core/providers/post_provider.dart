import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/post.dart';
import '../models/like.dart';
import '../repositories/post_repository.dart';

class PostProvider with ChangeNotifier {
  final PostRepository _postRepository;

  List<Post> _posts = [];
  List<Post> get posts => _posts;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Map<String, dynamic>? _validationErrors;
  Map<String, dynamic>? get validationErrors => _validationErrors;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isCreatingPost = false;
  bool get isCreatingPost => _isCreatingPost;

  PostProvider(this._postRepository);

  Future<void> getPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _postRepository.getPosts();

    if (response.success) {
      _posts = response.data ?? [];
    } else {
      _errorMessage = response.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createPost({required String content, File? image}) async {
    _isCreatingPost = true;
    _errorMessage = null;
    _validationErrors = null;
    notifyListeners();

    final response = await _postRepository.createPost(
      content: content,
      image: image,
    );

    if (response.success) {
      // Add the new post to the list
      _posts.insert(0, response.data!);
      _isCreatingPost = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      _validationErrors = response.errors;
      _isCreatingPost = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePost(int postId) async {
    _errorMessage = null;
    notifyListeners();

    final response = await _postRepository.deletePost(postId);

    if (response.success) {
      // Remove the post from the list
      _posts.removeWhere((post) => post.id == postId);
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleLike(int postId) async {
    _errorMessage = null;

    final response = await _postRepository.toggleLike(postId);

    if (response.success) {
      // Update the post in the list
      final index = _posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        final post = _posts[index];
        final isLiked = response.data!['status'] == 'liked';

        _posts[index] = Post(
          id: post.id,
          userId: post.userId,
          content: post.content,
          imageUrl: post.imageUrl,
          createdAt: post.createdAt,
          user: post.user,
          likesCount: isLiked ? post.likesCount + 1 : post.likesCount - 1,
          userLiked: isLiked,
        );
      }

      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  Future<List<Like>> getLikes(int postId) async {
    final response = await _postRepository.getLikes(postId);
    return response.success ? response.data ?? [] : [];
  }

  void clearErrors() {
    _errorMessage = null;
    _validationErrors = null;
    notifyListeners();
  }
}
