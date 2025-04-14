import 'user.dart';

class Like {
  final int userId;
  final int postId;
  final User user;

  Like({required this.userId, required this.postId, required this.user});

  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
      userId: json['user_id'] ?? 0,
      postId: json['post_id'] ?? 0,
      user: User.fromJson(json['user'] ?? {}),
    );
  }
}
