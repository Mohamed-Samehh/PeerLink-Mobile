import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/post.dart';
import '../repositories/user_repository.dart';
import '../repositories/post_repository.dart';

class UserProfileProvider with ChangeNotifier {
  final UserRepository _userRepository;
  final PostRepository _postRepository;

  User? _profileUser;
  User? get profileUser => _profileUser;

  List<Post> _userPosts = [];
  List<Post> get userPosts => _userPosts;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingPosts = false;
  bool get isLoadingPosts => _isLoadingPosts;

  UserProfileProvider(this._userRepository, this._postRepository);

  Future<void> getUserProfile(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _userRepository.getUserProfile(userId);

    if (response.success) {
      _profileUser = response.data;
    } else {
      _errorMessage = response.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> getUserPosts(int userId) async {
    _isLoadingPosts = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _postRepository.getUserPostsById(userId);

    if (response.success) {
      _userPosts = response.data ?? [];
    } else {
      _errorMessage = response.message;
    }

    _isLoadingPosts = false;
    notifyListeners();
  }

  Future<bool> toggleFollow(int userId) async {
    _errorMessage = null;

    final response = await _userRepository.toggleFollow(userId);

    if (response.success) {
      if (_profileUser != null && _profileUser!.id == userId) {
        final bool isFollowed = response.data!['status'] == 'followed';

        _profileUser = _profileUser!.copyWith(
          isFollowed: isFollowed,
          followersCount:
              isFollowed
                  ? (_profileUser!.followersCount ?? 0) + 1
                  : (_profileUser!.followersCount ?? 1) - 1,
        );

        notifyListeners();
      }

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

      final index = _userPosts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        final post = _userPosts[index];

        _userPosts[index] = Post(
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

  void clearProfile() {
    _profileUser = null;
    _userPosts = [];
    _errorMessage = null;
    _isLoading = false;
    _isLoadingPosts = false;
  }
}
