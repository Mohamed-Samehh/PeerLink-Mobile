import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';

class UserCard extends StatelessWidget {
  final User user;
  final VoidCallback onFollowToggle;
  final bool isFollowed;

  const UserCard({
    required this.user,
    required this.onFollowToggle,
    required this.isFollowed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  user.profilePictureUrl != null
                      ? CachedNetworkImageProvider(user.profilePictureUrl!)
                      : AssetImage('assets/images/placeholder.jpg'),
            ),
            SizedBox(height: 8),
            Text(
              user.name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text('@${user.username}'),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: onFollowToggle,
              child: Text(isFollowed ? 'Unfollow' : 'Follow'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
