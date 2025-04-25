import 'user.dart';

class Post {
  final int id;
  final int userId;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;
  final User? user;
  final int likesCount;
  final bool userLiked;

  Post({
    required this.id,
    required this.userId,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    this.user,
    this.likesCount = 0,
    this.userLiked = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    String? imageUrl = json['image_url'];

    if (imageUrl != null && !imageUrl.startsWith('http')) {
      imageUrl =
          'http://localhost:8000${imageUrl.startsWith('/') ? '' : '/'}$imageUrl';
      // 'http://10.0.2.2:8000' Android emulator and make sure to run "php artisan serve --host=0.0.0.0 --port=8000"
      // 'http://localhost:8000' Web or other platforms
    }

    User? postUser;
    if (json['user'] != null) {
      Map<String, dynamic> userJson = Map<String, dynamic>.from(json['user']);

      if (userJson['profile_picture_url'] == null &&
          userJson['profile_picture'] != null) {
        userJson['profile_picture_url'] =
            'http://localhost:8000/storage/${userJson['profile_picture']}';
        // 'http://10.0.2.2:8000/storage/' Android emulator and make sure to run "php artisan serve --host=0.0.0.0 --port=8000"
        // 'http://localhost:8000/storage/' Web or other platforms
      }

      postUser = User.fromJson(userJson);
    }

    return Post(
      id: json['id'],
      userId: json['user_id'],
      content: json['content'],
      imageUrl: imageUrl,
      createdAt: DateTime.parse(json['created_at']),
      user: postUser,
      likesCount: json['likes'] != null ? json['likes'].length : 0,
      userLiked: json['user_liked'] ?? false,
    );
  }
}
