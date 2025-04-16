import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/post.dart';
import '../models/like.dart';
import '../repositories/post_repository.dart';

class PostProvider with ChangeNotifier {
  final PostRepository _postRepository;

  List<Post> _posts = [];
  List<Post> get posts => _posts;

  List<Post> _userPosts = [];
  List<Post> get userPosts => _userPosts;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Map<String, dynamic>? _validationErrors;
  Map<String, dynamic>? get validationErrors => _validationErrors;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingUserPosts = false;
  bool get isLoadingUserPosts => _isLoadingUserPosts;

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

  Future<void> getUserPosts() async {
    _isLoadingUserPosts = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _postRepository.getUserPosts();

    if (response.success) {
      _userPosts = response.data ?? [];
    } else {
      _errorMessage = response.message;
    }

    _isLoadingUserPosts = false;
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

      // Also add to user posts if that list exists
      if (_userPosts.isNotEmpty) {
        _userPosts.insert(0, response.data!);
      }

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
      // Remove the post from both lists
      _posts.removeWhere((post) => post.id == postId);
      _userPosts.removeWhere((post) => post.id == postId);
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
      // Update the post in both lists
      final isLiked = response.data!['status'] == 'liked';

      _updatePostLike(_posts, postId, isLiked);
      _updatePostLike(_userPosts, postId, isLiked);

      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  void _updatePostLike(List<Post> postsList, int postId, bool isLiked) {
    final index = postsList.indexWhere((post) => post.id == postId);
    if (index != -1) {
      final post = postsList[index];
      postsList[index] = Post(
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
