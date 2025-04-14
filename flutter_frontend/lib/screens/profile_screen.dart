import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';
import '../widgets/post_card.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  void _fetchProfile() async {
    await Provider.of<AuthProvider>(context, listen: false).fetchProfile();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : user == null
              ? Center(child: Text('Unable to load profile'))
              : SingleChildScrollView(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage:
                          user.profilePictureUrl != null
                              ? CachedNetworkImageProvider(
                                user.profilePictureUrl!,
                              )
                              : AssetImage('assets/images/placeholder.jpg')
                                  as ImageProvider,
                    ),
                    SizedBox(height: 16),
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('@${user.username}'),
                    SizedBox(height: 8),
                    Text(user.bio ?? 'No bio'),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStat('Posts', '0'),
                        _buildStat('Followers', '0'),
                        _buildStat('Following', '0'),
                      ],
                    ),
                    SizedBox(height: 16),
                    Consumer<PostProvider>(
                      builder: (context, postProvider, child) {
                        final posts =
                            postProvider.posts
                                .where((post) => post.userId == user.id)
                                .toList();
                        return posts.isEmpty
                            ? Text('No posts yet')
                            : ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: posts.length,
                              itemBuilder:
                                  (context, index) =>
                                      PostCard(post: posts[index]),
                            );
                      },
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildStat(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label),
      ],
    );
  }
}
