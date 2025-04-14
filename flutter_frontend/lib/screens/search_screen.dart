import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../widgets/user_card.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<User> _users = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchUsers(String query) async {
    setState(() => _isLoading = true);
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
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connect')),
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
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: _searchUsers,
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
                          onFollowToggle: () async {
                            final apiService = ApiService();
                            final token = await _getToken();
                            final response = await apiService.post(
                              '/follow/${user.id}',
                              {},
                              token,
                            );
                            setState(() {
                              user.isFollowed =
                                  jsonDecode(response.body)['status'] ==
                                  'followed';
                            });
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
