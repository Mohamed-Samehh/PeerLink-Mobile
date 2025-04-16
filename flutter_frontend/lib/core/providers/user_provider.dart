import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';

class UserProvider with ChangeNotifier {
  final UserRepository _userRepository;

  User? _currentUser;
  User? get currentUser => _currentUser;

  List<User> _searchResults = [];
  List<User> get searchResults => _searchResults;

  List<User> _following = [];
  List<User> get following => _following;

  List<User> _followers = [];
  List<User> get followers => _followers;

  List<User> _followBack = [];
  List<User> get followBack => _followBack;

  List<User> _explore = [];
  List<User> get explore => _explore;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Map<String, dynamic>? _validationErrors;
  Map<String, dynamic>? get validationErrors => _validationErrors;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingSection = false;
  bool get isLoadingSection => _isLoadingSection;

  UserProvider(this._userRepository);

  Future<void> getProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _userRepository.getProfile();

    if (response.success) {
      _currentUser = response.data;
    } else {
      _errorMessage = response.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile({
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
    _isLoading = true;
    _errorMessage = null;
    _validationErrors = null;
    notifyListeners();

    final response = await _userRepository.updateProfile(
      name: name,
      username: username,
      email: email,
      phoneNum: phoneNum,
      dob: dob,
      gender: gender,
      bio: bio,
      profilePicture: profilePicture,
      removeProfilePicture: removeProfilePicture,
    );

    if (response.success) {
      _currentUser = response.data;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      _validationErrors = response.errors;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePassword({
    required String password,
    required String passwordConfirmation,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _validationErrors = null;
    notifyListeners();

    final response = await _userRepository.updatePassword(
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    if (response.success) {
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      _validationErrors = response.errors;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _userRepository.searchUsers(query);

    if (response.success) {
      _searchResults = response.data ?? [];
    } else {
      _errorMessage = response.message;
      _searchResults = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> getFollowing() async {
    _isLoadingSection = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _userRepository.getFollowing();

    if (response.success) {
      _following = response.data ?? [];
    } else {
      _errorMessage = response.message;
      _following = [];
    }

    _isLoadingSection = false;
    notifyListeners();
  }

  Future<void> getFollowers() async {
    _isLoadingSection = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _userRepository.getFollowers();

    if (response.success) {
      _followers = response.data ?? [];
    } else {
      _errorMessage = response.message;
      _followers = [];
    }

    _isLoadingSection = false;
    notifyListeners();
  }

  Future<void> getFollowBack() async {
    _isLoadingSection = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _userRepository.getFollowBack();

    if (response.success) {
      _followBack = response.data ?? [];
    } else {
      _errorMessage = response.message;
      _followBack = [];
    }

    _isLoadingSection = false;
    notifyListeners();
  }

  Future<void> getExplore() async {
    _isLoadingSection = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _userRepository.getExplore();

    if (response.success) {
      _explore = response.data ?? [];
    } else {
      _errorMessage = response.message;
      _explore = [];
    }

    _isLoadingSection = false;
    notifyListeners();
  }

  Future<bool> toggleFollow(int userId) async {
    _errorMessage = null;

    final response = await _userRepository.toggleFollow(userId);

    if (response.success) {
      // Update users in all lists
      _updateUserFollowStatus(userId, response.data!['status'] == 'followed');

      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  void _updateUserFollowStatus(int userId, bool isFollowed) {
    // Update search results
    for (int i = 0; i < _searchResults.length; i++) {
      if (_searchResults[i].id == userId) {
        _searchResults[i] = User(
          id: _searchResults[i].id,
          name: _searchResults[i].name,
          username: _searchResults[i].username,
          email: _searchResults[i].email,
          phoneNum: _searchResults[i].phoneNum,
          dob: _searchResults[i].dob,
          gender: _searchResults[i].gender,
          bio: _searchResults[i].bio,
          profilePictureUrl: _searchResults[i].profilePictureUrl,
          isFollowed: isFollowed,
          postsCount: _searchResults[i].postsCount,
          followersCount: _searchResults[i].followersCount,
          followingCount: _searchResults[i].followingCount,
        );
      }
    }

    // Update followers
    for (int i = 0; i < _followers.length; i++) {
      if (_followers[i].id == userId) {
        _followers[i] = User(
          id: _followers[i].id,
          name: _followers[i].name,
          username: _followers[i].username,
          email: _followers[i].email,
          phoneNum: _followers[i].phoneNum,
          dob: _followers[i].dob,
          gender: _followers[i].gender,
          bio: _followers[i].bio,
          profilePictureUrl: _followers[i].profilePictureUrl,
          isFollowed: isFollowed,
          postsCount: _followers[i].postsCount,
          followersCount: _followers[i].followersCount,
          followingCount: _followers[i].followingCount,
        );
      }
    }

    // Update follow back
    List<User> updatedFollowBack = [];
    for (int i = 0; i < _followBack.length; i++) {
      if (_followBack[i].id == userId) {
        if (!isFollowed) {
          updatedFollowBack.add(
            User(
              id: _followBack[i].id,
              name: _followBack[i].name,
              username: _followBack[i].username,
              email: _followBack[i].email,
              phoneNum: _followBack[i].phoneNum,
              dob: _followBack[i].dob,
              gender: _followBack[i].gender,
              bio: _followBack[i].bio,
              profilePictureUrl: _followBack[i].profilePictureUrl,
              isFollowed: isFollowed,
              postsCount: _followBack[i].postsCount,
              followersCount: _followBack[i].followersCount,
              followingCount: _followBack[i].followingCount,
            ),
          );
        }
        // If followed, remove from follow back list
      } else {
        updatedFollowBack.add(_followBack[i]);
      }
    }
    _followBack = updatedFollowBack;

    // Update explore
    List<User> updatedExplore = [];
    for (int i = 0; i < _explore.length; i++) {
      if (_explore[i].id == userId) {
        if (!isFollowed) {
          updatedExplore.add(
            User(
              id: _explore[i].id,
              name: _explore[i].name,
              username: _explore[i].username,
              email: _explore[i].email,
              phoneNum: _explore[i].phoneNum,
              dob: _explore[i].dob,
              gender: _explore[i].gender,
              bio: _explore[i].bio,
              profilePictureUrl: _explore[i].profilePictureUrl,
              isFollowed: isFollowed,
              postsCount: _explore[i].postsCount,
              followersCount: _explore[i].followersCount,
              followingCount: _explore[i].followingCount,
            ),
          );
        }
        // If followed, remove from explore list
      } else {
        updatedExplore.add(_explore[i]);
      }
    }
    _explore = updatedExplore;

    // Update following list
    if (isFollowed) {
      final existingIndex = _following.indexWhere((user) => user.id == userId);
      if (existingIndex == -1) {
        User? userToAdd;
        for (final user in [
          ..._followers,
          ..._followBack,
          ..._explore,
          ..._searchResults,
        ]) {
          if (user.id == userId) {
            userToAdd = User(
              id: user.id,
              name: user.name,
              username: user.username,
              email: user.email,
              phoneNum: user.phoneNum,
              dob: user.dob,
              gender: user.gender,
              bio: user.bio,
              profilePictureUrl: user.profilePictureUrl,
              isFollowed: true,
              postsCount: user.postsCount,
              followersCount: user.followersCount,
              followingCount: user.followingCount,
            );
            break;
          }
        }
        if (userToAdd != null) {
          _following.add(userToAdd);
        }
      }
    } else {
      // Remove from following list if unfollowed
      _following.removeWhere((user) => user.id == userId);
    }
  }

  void clearErrors() {
    _errorMessage = null;
    _validationErrors = null;
    notifyListeners();
  }
}
