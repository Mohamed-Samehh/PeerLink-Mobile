import '../utils/constants.dart';

class User {
  final int id;
  final String name;
  final String username;
  final String email;
  final String? phoneNum;
  final String? dob;
  final String? gender;
  final String? bio;
  final String? profilePictureUrl;
  bool? isFollowed;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.phoneNum,
    this.dob,
    this.gender,
    this.bio,
    this.profilePictureUrl,
    this.isFollowed,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phoneNum: json['phone_num'],
      dob: json['dob'],
      gender: json['gender'],
      bio: json['bio'],
      profilePictureUrl: getImageUrl(json['profile_picture_url']),
      isFollowed:
          json['is_followed'] != null ? json['is_followed'] == 1 : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'username': username,
      'email': email,
      'phone_num': phoneNum,
      'dob': dob,
      'gender': gender,
      'bio': bio,
    };
  }

  // Validation helpers
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(value)) {
      return 'Username must be 3-20 characters (letters, numbers, underscores)';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!RegExp(r'^\+?\d{10,15}$').hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? validateBio(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.length > 150) {
      return 'Bio must be 150 characters or less';
    }
    return null;
  }
}
