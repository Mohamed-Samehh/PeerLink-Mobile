import 'user.dart';
import '../utils/constants.dart';

class Post {
  final int id;
  final int userId;
  final String content;
  final String? imageUrl;
  final String createdAt;
  final User user;
  final int likeCount;
  final bool userLiked;

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
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      content: json['content'] ?? '',
      imageUrl: getImageUrl(json['image_url']),
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
      user: User.fromJson(json['user'] ?? {}),
      likeCount: json['likes'] != null ? (json['likes'] as List).length : 0,
      userLiked: json['user_liked'] ?? false,
    );
  }

  static String? validateContent(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Post content is required';
    }
    if (value.length > 500) {
      return 'Post must be 500 characters or less';
    }
    return null;
  }
}
