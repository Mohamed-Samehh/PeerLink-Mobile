import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/user.dart';
import '../shared/user_list_item.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);

    // Load initial data for the first tab
    Future.microtask(() {
      _loadTabData(0);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.index != _currentTabIndex) {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
      _loadTabData(_currentTabIndex);
    }
  }

  void _loadTabData(int tabIndex) {
    final userProvider = context.read<UserProvider>();

    switch (tabIndex) {
      case 0: // Following
        userProvider.getFollowing();
        break;
      case 1: // Followers
        userProvider.getFollowers();
        break;
      case 2: // Follow Back
        userProvider.getFollowBack();
        break;
      case 3: // Explore
        userProvider.getExplore();
        break;
    }
  }

  void _search(String query) {
    if (_currentTabIndex == 3) {
      // Only search in Explore tab
      final userProvider = context.read<UserProvider>();
      userProvider.searchUsers(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover People'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
          tabs: const [
            Tab(text: 'Following'),
            Tab(text: 'Followers'),
            Tab(text: 'Follow Back'),
            Tab(text: 'Explore'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar - only shown in Explore tab
          if (_currentTabIndex == 3)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by username',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: _search,
              ),
            ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Following Tab
                _buildUserList(
                  userProvider.following,
                  userProvider.isLoadingSection,
                  'You are not following anyone yet',
                  userProvider,
                ),

                // Followers Tab
                _buildUserList(
                  userProvider.followers,
                  userProvider.isLoadingSection,
                  'You do not have any followers yet',
                  userProvider,
                ),

                // Follow Back Tab
                _buildUserList(
                  userProvider.followBack,
                  userProvider.isLoadingSection,
                  'No one to follow back',
                  userProvider,
                ),

                // Explore Tab
                _currentTabIndex == 3 && _searchController.text.isNotEmpty
                    ? _buildUserList(
                      userProvider.searchResults,
                      userProvider.isLoading,
                      'No users found',
                      userProvider,
                    )
                    : _buildUserList(
                      userProvider.explore,
                      userProvider.isLoadingSection,
                      'No users to explore',
                      userProvider,
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(
    List<User> users,
    bool isLoading,
    String emptyMessage,
    UserProvider userProvider,
  ) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (users.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadTabData(_currentTabIndex);
      },
      color: AppColors.primary,
      child: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return UserListItem(
            user: user,
            onToggleFollow: () async {
              await userProvider.toggleFollow(user.id);
            },
          );
        },
      ),
    );
  }
}
