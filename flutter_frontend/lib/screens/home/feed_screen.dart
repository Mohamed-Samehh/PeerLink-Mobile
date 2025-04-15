import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/post_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../shared/post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PostProvider>().getPosts();
    });
  }

  Future<void> _refreshFeed() async {
    await context.read<PostProvider>().getPosts();
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = context.watch<PostProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Social App',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            color: AppColors.primary,
            onPressed: () async {
              await authProvider.logout();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshFeed,
        color: AppColors.primary,
        child:
            postProvider.isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
                : postProvider.posts.isEmpty
                ? const Center(
                  child: Text(
                    'No posts to show.\nFollow other users or create a post.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
                : ListView.builder(
                  itemCount: postProvider.posts.length,
                  itemBuilder: (context, index) {
                    final post = postProvider.posts[index];
                    return PostCard(
                      post: post,
                      isCurrentUser: post.userId == user?.id,
                      onDelete: () async {
                        final success = await postProvider.deletePost(post.id);
                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Post deleted successfully'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      },
                      onLike: () async {
                        await postProvider.toggleLike(post.id);
                      },
                    );
                  },
                ),
      ),
    );
  }
}
