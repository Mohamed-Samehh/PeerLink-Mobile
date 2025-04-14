import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/post.dart';
import '../providers/post_provider.dart';
import 'package:provider/provider.dart';

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[200],
                  backgroundImage:
                      post.user.profilePictureUrl != null &&
                              post.user.profilePictureUrl!.isNotEmpty
                          ? CachedNetworkImageProvider(
                            post.user.profilePictureUrl!,
                          )
                          : null,
                  child:
                      post.user.profilePictureUrl == null ||
                              post.user.profilePictureUrl!.isEmpty
                          ? Icon(
                            Icons.person,
                            size: 24,
                            color: Colors.grey[600],
                          )
                          : null,
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.user.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '@${post.user.username}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              post.content,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: post.imageUrl!,
                    placeholder:
                        (context, url) => Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    errorWidget:
                        (context, url, error) => Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: Center(
                            child: Icon(Icons.broken_image, size: 50),
                          ),
                        ),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                  ),
                ),
              ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        post.userLiked ? Icons.favorite : Icons.favorite_border,
                        color:
                            post.userLiked
                                ? Theme.of(context).colorScheme.secondary
                                : Colors.grey[600],
                      ),
                      onPressed: () {
                        Provider.of<PostProvider>(
                          context,
                          listen: false,
                        ).toggleLike(post.id);
                      },
                    ),
                    GestureDetector(
                      onTap: () async {
                        final likes = await Provider.of<PostProvider>(
                          context,
                          listen: false,
                        ).fetchLikes(post.id);
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: Text('Likes'),
                                content: Container(
                                  width: double.maxFinite,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: likes.length,
                                    itemBuilder: (context, index) {
                                      final like = likes[index];
                                      return ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.grey[200],
                                          backgroundImage:
                                              like.user.profilePictureUrl !=
                                                      null
                                                  ? CachedNetworkImageProvider(
                                                    like
                                                        .user
                                                        .profilePictureUrl!,
                                                  )
                                                  : null,
                                          child:
                                              like.user.profilePictureUrl ==
                                                      null
                                                  ? Icon(
                                                    Icons.person,
                                                    size: 20,
                                                    color: Colors.grey[600],
                                                  )
                                                  : null,
                                        ),
                                        title: Text(like.user.name),
                                        subtitle: Text(
                                          '@${like.user.username}',
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Close'),
                                  ),
                                ],
                              ),
                        );
                      },
                      child: Text(
                        '${post.likeCount}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
                Text(
                  DateFormat(
                    'MMM d, yyyy',
                  ).format(DateTime.parse(post.createdAt)),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
