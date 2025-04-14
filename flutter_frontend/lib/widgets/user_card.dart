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
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[200],
              backgroundImage:
                  user.profilePictureUrl != null &&
                          user.profilePictureUrl!.isNotEmpty
                      ? CachedNetworkImageProvider(user.profilePictureUrl!)
                      : null,
              child:
                  user.profilePictureUrl == null ||
                          user.profilePictureUrl!.isEmpty
                      ? Icon(Icons.person, size: 50, color: Colors.grey[600])
                      : null,
            ),
            SizedBox(height: 12),
            Text(
              user.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              '@${user.username}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: onFollowToggle,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isFollowed
                        ? Colors.grey[300]
                        : Theme.of(context).primaryColor,
                foregroundColor: isFollowed ? Colors.black87 : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(isFollowed ? 'Unfollow' : 'Follow'),
            ),
          ],
        ),
      ),
    );
  }
}
