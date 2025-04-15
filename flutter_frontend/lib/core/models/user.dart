class User {
  final int id;
  final String name;
  final String username;
  final String email;
  final String? phoneNum;
  final String dob;
  final String gender;
  final String? bio;
  final String? profilePictureUrl;
  final bool isFollowed;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.phoneNum,
    required this.dob,
    required this.gender,
    this.bio,
    this.profilePictureUrl,
    this.isFollowed = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    String? profilePictureUrl = json['profile_picture_url'];

    if (profilePictureUrl != null && !profilePictureUrl.startsWith('http')) {
      profilePictureUrl =
          'http://127.0.0.1:8000${profilePictureUrl.startsWith('/') ? '' : '/'}$profilePictureUrl';
    }

    return User(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      email: json['email'],
      phoneNum: json['phone_num'],
      dob: json['dob'],
      gender: json['gender'],
      bio: json['bio'],
      profilePictureUrl: profilePictureUrl,
      isFollowed: json['is_followed'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'phone_num': phoneNum,
      'dob': dob,
      'gender': gender,
      'bio': bio,
      'profile_picture_url': profilePictureUrl,
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? username,
    String? email,
    String? phoneNum,
    String? dob,
    String? gender,
    String? bio,
    String? profilePictureUrl,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNum: phoneNum ?? this.phoneNum,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      isFollowed: isFollowed,
    );
  }
}
