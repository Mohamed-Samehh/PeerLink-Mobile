import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../profile/edit_profile_screen.dart';
import '../profile/change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<UserProvider>().getProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
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
      body:
          userProvider.isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
              : user == null
              ? const Center(child: Text('Failed to load profile'))
              : SingleChildScrollView(
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

                    // Profile info card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Email
                            ListTile(
                              leading: const Icon(
                                Icons.email,
                                color: AppColors.primary,
                              ),
                              title: const Text('Email'),
                              subtitle: Text(user.email),
                              dense: true,
                            ),

                            // Phone
                            if (user.phoneNum != null &&
                                user.phoneNum!.isNotEmpty)
                              ListTile(
                                leading: const Icon(
                                  Icons.phone,
                                  color: AppColors.primary,
                                ),
                                title: const Text('Phone'),
                                subtitle: Text(user.phoneNum!),
                                dense: true,
                              ),

                            // Gender
                            ListTile(
                              leading: const Icon(
                                Icons.people,
                                color: AppColors.primary,
                              ),
                              title: const Text('Gender'),
                              subtitle: Text(user.gender),
                              dense: true,
                            ),

                            // DOB
                            ListTile(
                              leading: const Icon(
                                Icons.calendar_today,
                                color: AppColors.primary,
                              ),
                              title: const Text('Date of Birth'),
                              subtitle: Text(user.dob),
                              dense: true,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Edit profile button
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
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
                  ],
                ),
              ),
    );
  }
}
