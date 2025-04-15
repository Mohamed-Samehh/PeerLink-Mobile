import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/models/post.dart';
import '../../core/constants/app_colors.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final bool isCurrentUser;
  final VoidCallback onDelete;
  final VoidCallback onLike;

  const PostCard({
    super.key,
    required this.post,
    required this.isCurrentUser,
    required this.onDelete,
    required this.onLike,
  });

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Post'),
          content: const Text('Are you sure you want to delete this post?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onDelete();
              },
              child: const Text(
                'DELETE',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // User avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryLight,
                  backgroundImage:
                      post.user?.profilePictureUrl != null
                          ? NetworkImage(post.user!.profilePictureUrl!)
                          : null,
                  child:
                      post.user?.profilePictureUrl == null
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                ),
                const SizedBox(width: 12),

                // User info and post date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.user?.name ?? 'Unknown',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '@${post.user?.username ?? 'unknown'} • ${dateFormat.format(post.createdAt)}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Post content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(post.content, style: const TextStyle(fontSize: 16)),
          ),

          // Post image
          if (post.imageUrl != null)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Image.network(
                post.imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                height: 250,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  );
                },
              ),
            ),

          // Post actions (like and delete)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Like button and count
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        post.userLiked ? Icons.favorite : Icons.favorite_border,
                        color: post.userLiked ? AppColors.accent : null,
                      ),
                      onPressed: onLike,
                    ),
                    Text(
                      '${post.likesCount}',
                      style: TextStyle(
                        color:
                            post.userLiked
                                ? AppColors.accent
                                : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                // Delete button (only for current user's posts)
                if (isCurrentUser)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                    ),
                    onPressed: () => _showDeleteConfirmation(context),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
