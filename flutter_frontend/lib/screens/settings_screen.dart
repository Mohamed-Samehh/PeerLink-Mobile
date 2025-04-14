import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import './auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _passwordController = TextEditingController();
  DateTime? _dob;
  String? _gender;
  File? _profilePicture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _nameController.text = user.name;
      _usernameController.text = user.username;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNum ?? '';
      _bioController.text = user.bio ?? '';
      _dob = user.dob != null ? DateTime.parse(user.dob!) : null;
      _gender = user.gender;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profilePicture = File(pickedFile.path);
      });
    }
  }

  void _updateProfile() async {
    setState(() => _isLoading = true);
    final success = await Provider.of<AuthProvider>(
      context,
      listen: false,
    ).updateProfile(
      name: _nameController.text,
      username: _usernameController.text,
      email: _emailController.text,
      phoneNum: _phoneController.text,
      dob: _dob?.toIso8601String().split('T')[0],
      gender: _gender,
      bio: _bioController.text,
      profilePicture: _profilePicture,
    );
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Profile updated')));
    }
  }

  void _updatePassword() async {
    if (_passwordController.text.isNotEmpty) {
      setState(() => _isLoading = true);
      final success = await Provider.of<AuthProvider>(
        context,
        listen: false,
      ).updatePassword(_passwordController.text);
      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Password updated')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(label: 'Name', controller: _nameController),
            SizedBox(height: 16),
            CustomTextField(label: 'Username', controller: _usernameController),
            SizedBox(height: 16),
            CustomTextField(
              label: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            CustomTextField(
              label: 'Phone Number',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),
            CustomTextField(label: 'Bio', controller: _bioController),
            SizedBox(height: 16),
            ListTile(
              title: Text(
                _dob == null
                    ? 'Select Date of Birth'
                    : _dob!.toString().split(' ')[0],
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _dob ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _dob = date);
                }
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _gender,
              hint: Text('Select Gender'),
              items:
                  ['Male', 'Female'].map((gender) {
                    return DropdownMenuItem(value: gender, child: Text(gender));
                  }).toList(),
              onChanged: (value) => setState(() => _gender = value),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 16),
            ListTile(
              leading:
                  _profilePicture == null
                      ? Icon(Icons.image)
                      : Image.file(
                        _profilePicture!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
              title: Text('Change Profile Picture'),
              onTap: _pickImage,
            ),
            SizedBox(height: 16),
            CustomButton(
              text: 'Update Profile',
              onPressed: _updateProfile,
              isLoading: _isLoading,
            ),
            SizedBox(height: 24),
            CustomTextField(
              label: 'New Password',
              controller: _passwordController,
              obscureText: true,
            ),
            SizedBox(height: 16),
            CustomButton(
              text: 'Update Password',
              onPressed: _updatePassword,
              isLoading: _isLoading,
            ),
            SizedBox(height: 24),
            CustomButton(
              text: 'Logout',
              onPressed: () async {
                await Provider.of<AuthProvider>(
                  context,
                  listen: false,
                ).logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
