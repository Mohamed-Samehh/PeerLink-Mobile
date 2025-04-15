import 'package:flutter/material.dart';
import '../../core/models/user.dart';
import '../../core/constants/app_colors.dart';

class UserListItem extends StatelessWidget {
  final User user;
  final VoidCallback onToggleFollow;

  const UserListItem({
    super.key,
    required this.user,
    required this.onToggleFollow,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primaryLight,
        backgroundImage:
            user.profilePictureUrl != null
                ? NetworkImage(user.profilePictureUrl!)
                : null,
        child:
            user.profilePictureUrl == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
      ),
      title: Text(
        user.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text('@${user.username}'),
      trailing: ElevatedButton(
        onPressed: onToggleFollow,
        style: ElevatedButton.styleFrom(
          backgroundColor: user.isFollowed ? Colors.white : AppColors.primary,
          foregroundColor: user.isFollowed ? AppColors.primary : Colors.white,
          elevation: 0,
          side:
              user.isFollowed
                  ? const BorderSide(color: AppColors.primary)
                  : null,
          minimumSize: const Size(100, 36),
          padding: EdgeInsets.zero,
        ),
        child: Text(user.isFollowed ? 'Unfollow' : 'Follow'),
      ),
    );
  }
}
