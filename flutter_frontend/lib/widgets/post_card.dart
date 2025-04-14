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
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      post.user.profilePictureUrl != null
                          ? CachedNetworkImageProvider(
                            post.user.profilePictureUrl!,
                          )
                          : AssetImage('assets/images/placeholder.jpg'),
                ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.user.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('@${post.user.username}'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(post.content),
            if (post.imageUrl != null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: post.imageUrl!,
                    placeholder:
                        (context, url) =>
                            Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        post.userLiked ? Icons.favorite : Icons.favorite_border,
                        color: post.userLiked ? Colors.red : null,
                      ),
                      onPressed: () {
                        Provider.of<PostProvider>(
                          context,
                          listen: false,
                        ).toggleLike(post.id);
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        // Show likes dialog
                      },
                      child: Text('${post.likeCount}'),
                    ),
                  ],
                ),
                Text(
                  DateFormat(
                    'MMM d, yyyy',
                  ).format(DateTime.parse(post.createdAt)),
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
