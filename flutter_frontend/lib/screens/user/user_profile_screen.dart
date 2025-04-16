import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_profile_provider.dart';
import '../../core/constants/app_colors.dart';
import '../shared/post_card.dart';

class UserProfileScreen extends StatefulWidget {
  final int userId;
  final String? username;

  const UserProfileScreen({super.key, required this.userId, this.username});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late UserProfileProvider _profileProvider;

  @override
  void initState() {
    super.initState();
    _profileProvider = Provider.of<UserProfileProvider>(context, listen: false);

    // Load the profile data
    Future.microtask(() {
      _profileProvider.getUserProfile(widget.userId);
      _profileProvider.getUserPosts(widget.userId);
    });
  }

  @override
  void dispose() {
    super.dispose();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _profileProvider.clearProfile();
    });
  }

  Future<void> _refreshProfile() async {
    await _profileProvider.getUserProfile(widget.userId);
    await _profileProvider.getUserPosts(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<UserProfileProvider>();
    final user = profileProvider.profileUser;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        title: Text(widget.username ?? 'Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        child:
            profileProvider.isLoading
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatColumn('Posts', user.postsCount ?? 0),
                          Container(
                            height: 40,
                            width: 1,
                            color: AppColors.divider,
                          ),
                          _buildStatColumn(
                            'Followers',
                            user.followersCount ?? 0,
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: AppColors.divider,
                          ),
                          _buildStatColumn(
                            'Following',
                            user.followingCount ?? 0,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Follow/Unfollow button
                      ElevatedButton.icon(
                        onPressed: () async {
                          await profileProvider.toggleFollow(user.id);
                        },
                        label: Text(user.isFollowed ? 'Unfollow' : 'Follow'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              user.isFollowed
                                  ? Colors.white
                                  : AppColors.primary,
                          foregroundColor:
                              user.isFollowed
                                  ? AppColors.primary
                                  : Colors.white,
                          side:
                              user.isFollowed
                                  ? const BorderSide(color: AppColors.primary)
                                  : null,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
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
                      _buildUserPosts(context, profileProvider),
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

  Widget _buildUserPosts(
    BuildContext context,
    UserProfileProvider profileProvider,
  ) {
    if (profileProvider.isLoadingPosts) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (profileProvider.userPosts.isEmpty) {
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
      itemCount: profileProvider.userPosts.length,
      itemBuilder: (context, index) {
        final post = profileProvider.userPosts[index];
        return PostCard(
          post: post,
          isCurrentUser: false, // Not the current user
          onDelete: () async {
            // Do nothing as it's not the current user's post
          },
          onLike: () async {
            await profileProvider.toggleLike(post.id);
          },
        );
      },
    );
  }
}
