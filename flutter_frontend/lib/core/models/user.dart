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
  final int? postsCount;
  final int? followersCount;
  final int? followingCount;

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
    this.postsCount,
    this.followersCount,
    this.followingCount,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    String? profilePictureUrl = json['profile_picture_url'];

    if (profilePictureUrl == null && json['profile_picture'] != null) {
      profilePictureUrl =
          'http://localhost:8000/storage/${json['profile_picture']}';
      // 'http://10.0.2.2:8000/storage/ Android emulator and make sure to run "php artisan serve --host=0.0.0.0 --port=8000"
      // 'http://localhost:8000/storage/' Web or other platforms
    }

    if (profilePictureUrl != null && !profilePictureUrl.startsWith('http')) {
      profilePictureUrl =
          'http://localhost:8000${profilePictureUrl.startsWith('/') ? '' : '/'}$profilePictureUrl';
      // 'http://10.0.2.2:8000' Android emulator and make sure to run "php artisan serve --host=0.0.0.0 --port=8000"
      // 'http://localhost:8000' Web or other platforms
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
      postsCount: json['posts_count'],
      followersCount: json['followers_count'],
      followingCount: json['following_count'],
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
      'is_followed': isFollowed ? 1 : 0,
      'posts_count': postsCount,
      'followers_count': followersCount,
      'following_count': followingCount,
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
    bool? isFollowed,
    int? postsCount,
    int? followersCount,
    int? followingCount,
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
      isFollowed: isFollowed ?? this.isFollowed,
      postsCount: postsCount ?? this.postsCount,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
    );
  }
}
