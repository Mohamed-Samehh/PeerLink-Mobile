import 'user.dart';

class Like {
  final int id;
  final int userId;
  final int postId;
  final User user;

  Like({
    required this.id,
    required this.userId,
    required this.postId,
    required this.user,
  });

  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
      id: json['id'],
      userId: json['user_id'],
      postId: json['post_id'],
      user: User.fromJson(json['user']),
    );
  }
}
