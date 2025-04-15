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

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Map<String, dynamic>? _validationErrors;
  Map<String, dynamic>? get validationErrors => _validationErrors;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

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

  Future<bool> toggleFollow(int userId) async {
    _errorMessage = null;

    final response = await _userRepository.toggleFollow(userId);

    if (response.success) {
      // Update search results
      _searchResults =
          _searchResults.map((user) {
            if (user.id == userId) {
              return User(
                id: user.id,
                name: user.name,
                username: user.username,
                email: user.email,
                phoneNum: user.phoneNum,
                dob: user.dob,
                gender: user.gender,
                bio: user.bio,
                profilePictureUrl: user.profilePictureUrl,
                isFollowed: !user.isFollowed,
              );
            }
            return user;
          }).toList();

      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  void clearErrors() {
    _errorMessage = null;
    _validationErrors = null;
    notifyListeners();
  }
}
