import 'user.dart';

class Post {
  final int id;
  final int userId;
  final String content;
  final String? imageUrl;
  final String createdAt;
  final User user;
  int likeCount;
  bool userLiked;

  Post({
    required this.id,
    required this.userId,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    required this.user,
    required this.likeCount,
    required this.userLiked,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['user_id'],
      content: json['content'],
      imageUrl: json['image_url'],
      createdAt: json['created_at'],
      user: User.fromJson(json['user']),
      likeCount: json['likes']?.length ?? 0,
      userLiked: json['user_liked'] ?? false,
    );
  }
}
