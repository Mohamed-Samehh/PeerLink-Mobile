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
          'http://127.0.0.1:8000${imageUrl.startsWith('/') ? '' : '/'}$imageUrl';
    }

    return Post(
      id: json['id'],
      userId: json['user_id'],
      content: json['content'],
      imageUrl: imageUrl,
      createdAt: DateTime.parse(json['created_at']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      likesCount: json['likes'] != null ? json['likes'].length : 0,
      userLiked: json['user_liked'] ?? false,
    );
  }
}
