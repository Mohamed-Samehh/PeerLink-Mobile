import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../widgets/user_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<User> _users = [];
  bool _isLoading = false;
  String? _searchError;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _validateAndSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchError = 'Search term is required';
      });
      return;
    }
    if (!RegExp(r'^[a-zA-Z0-9_ ]{1,50}$').hasMatch(query)) {
      setState(() {
        _searchError =
            'Search can only contain letters, numbers, underscores, and spaces';
      });
      return;
    }

    setState(() {
      _searchError = null;
      _isLoading = true;
    });
    try {
      final apiService = ApiService();
      final token = await _getToken();
      final response = await apiService.get('/search?search=$query', token);
      setState(() {
        _users =
            (jsonDecode(response.body) as List)
                .map((data) => User.fromJson(data))
                .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Search failed: $e')));
    }
  }

  void _toggleFollow(User user, int index) async {
    try {
      final apiService = ApiService();
      final token = await _getToken();
      final response = await apiService.post('/follow/${user.id}', {}, token);
      final status = jsonDecode(response.body)['status'] ?? '';
      setState(() {
        _users[index].isFollowed = status == 'followed';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'followed'
                ? 'Followed ${user.username}'
                : 'Unfollowed ${user.username}',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to toggle follow: $e')));
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connect'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Username',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: _searchError,
              ),
              onSubmitted: _validateAndSearch,
              onChanged:
                  (value) => setState(() {
                    _searchError = null;
                  }),
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _users.isEmpty
                    ? Center(child: Text('No users found'))
                    : ListView.builder(
                      itemCount: _users.length,
                      itemBuilder: (context, index) {
                        final user = _users[index];
                        return UserCard(
                          user: user,
                          isFollowed: user.isFollowed ?? false,
                          onFollowToggle: () => _toggleFollow(user, index),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
