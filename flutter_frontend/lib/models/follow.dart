class Follow {
  final int followerId;
  final int followedId;

  Follow({required this.followerId, required this.followedId});

  factory Follow.fromJson(Map<String, dynamic> json) {
    return Follow(
      followerId: json['follower_id'] ?? 0,
      followedId: json['followed_id'] ?? 0,
    );
  }
}
