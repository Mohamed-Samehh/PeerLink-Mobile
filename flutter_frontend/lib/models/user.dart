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
      id: json['id'],
      name: json['name'],
      username: json['username'],
      email: json['email'],
      phoneNum: json['phone_num'],
      dob: json['dob'],
      gender: json['gender'],
      bio: json['bio'],
      profilePictureUrl: json['profile_picture_url'],
      isFollowed: json['is_followed'] != null ? json['is_followed'] == 1 : null,
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
}
