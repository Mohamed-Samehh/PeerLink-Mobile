import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/post_provider.dart';
import '../../core/constants/app_colors.dart';
import '../profile/edit_profile_screen.dart';
import '../profile/change_password_screen.dart';
import '../shared/post_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _postsCount = 0;
  int _followersCount = 0;
  int _followingCount = 0;
  bool _isLoadingStats = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        final userProvider = context.read<UserProvider>();
        userProvider.getProfile();
        _loadUserStats();
      }
    });
  }

  Future<void> _loadUserStats() async {
    setState(() {
      _isLoadingStats = true;
    });

    try {
      // Get posts count
      final postProvider = context.read<PostProvider>();
      await postProvider.getUserPosts();

      // Get followers and following counts
      if (mounted) {
        final userProvider = context.read<UserProvider>();
        await userProvider.getFollowers();
        await userProvider.getFollowing();

        setState(() {
          _postsCount = postProvider.userPosts.length;
          _followersCount = userProvider.followers.length;
          _followingCount = userProvider.following.length;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
    }
  }

  void _showDeleteSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post deleted successfully'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                ).then((_) => _loadUserStats());
              } else if (value == 'password') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordScreen(),
                  ),
                );
              } else if (value == 'logout') {
                context.read<AuthProvider>().logout();
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Text('Edit Profile'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'password',
                    child: Text('Change Password'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Text('Logout'),
                  ),
                ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<UserProvider>().getProfile();
          await _loadUserStats();
        },
        child:
            userProvider.isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
                : user == null
                ? const Center(child: Text('Failed to load profile'))
                : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile picture
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.primaryLight,
                        backgroundImage:
                            user.profilePictureUrl != null
                                ? NetworkImage(user.profilePictureUrl!)
                                : null,
                        child:
                            user.profilePictureUrl == null
                                ? const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white,
                                )
                                : null,
                      ),
                      const SizedBox(height: 16),

                      // Username
                      Text(
                        '@${user.username}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Full name
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Bio
                      if (user.bio != null && user.bio!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            user.bio!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Stats Row (Posts, Followers, Following)
                      _isLoadingStats
                          ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatColumn('Posts', _postsCount),
                              Container(
                                height: 40,
                                width: 1,
                                color: AppColors.divider,
                              ),
                              _buildStatColumn('Followers', _followersCount),
                              Container(
                                height: 40,
                                width: 1,
                                color: AppColors.divider,
                              ),
                              _buildStatColumn('Following', _followingCount),
                            ],
                          ),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Edit profile button
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          ).then((_) => _loadUserStats());
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Profile'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          foregroundColor: AppColors.primary,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // User posts header
                      const Row(
                        children: [
                          Icon(Icons.grid_on, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text(
                            'Posts',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // User posts
                      _buildUserPosts(),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildStatColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildUserPosts() {
    final postProvider = context.watch<PostProvider>();

    if (postProvider.isLoadingUserPosts) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (postProvider.userPosts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'No posts yet',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: postProvider.userPosts.length,
      itemBuilder: (context, index) {
        final post = postProvider.userPosts[index];
        return PostCard(
          post: post,
          isCurrentUser: true,
          onDelete: () async {
            final success = await postProvider.deletePost(post.id);
            if (!mounted) return;

            if (success) {
              _showDeleteSuccessSnackBar();
              _loadUserStats();
            }
          },
          onLike: () async {
            await postProvider.toggleLike(post.id);
          },
        );
      },
    );
  }
}
