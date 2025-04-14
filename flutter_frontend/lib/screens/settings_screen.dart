import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import './auth/login_screen.dart';
import '../../models/user.dart';

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
  String? _nameError;
  String? _usernameError;
  String? _emailError;
  String? _phoneError;
  String? _bioError;
  String? _passwordError;

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

  void _validateAndUpdateProfile() async {
    setState(() {
      _nameError = User.validateName(_nameController.text);
      _usernameError = User.validateUsername(_usernameController.text);
      _emailError = User.validateEmail(_emailController.text);
      _phoneError = User.validatePhone(_phoneController.text);
      _bioError = User.validateBio(_bioController.text);
    });

    if (_nameError == null &&
        _usernameError == null &&
        _emailError == null &&
        _phoneError == null &&
        _bioError == null) {
      setState(() => _isLoading = true);
      final success = await Provider.of<AuthProvider>(
        context,
        listen: false,
      ).updateProfile(
        name: _nameController.text,
        username: _usernameController.text,
        email: _emailController.text,
        phoneNum: _phoneController.text.isEmpty ? null : _phoneController.text,
        dob: _dob?.toIso8601String().split('T')[0],
        gender: _gender,
        bio: _bioController.text.isEmpty ? null : _bioController.text,
        profilePicture: _profilePicture,
      );
      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Provider.of<AuthProvider>(context, listen: false).error ??
                  'Failed to update profile',
            ),
          ),
        );
      }
    }
  }

  void _validateAndUpdatePassword() async {
    setState(() {
      _passwordError =
          _passwordController.text.isEmpty
              ? null
              : _passwordController.text.length < 8
              ? 'Password must be at least 8 characters'
              : !RegExp(
                r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
              ).hasMatch(_passwordController.text)
              ? 'Password must contain letters and numbers'
              : null;
    });

    if (_passwordController.text.isNotEmpty && _passwordError == null) {
      setState(() => _isLoading = true);
      final success = await Provider.of<AuthProvider>(
        context,
        listen: false,
      ).updatePassword(_passwordController.text);
      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Provider.of<AuthProvider>(context, listen: false).error ??
                  'Failed to update password',
            ),
          ),
        );
      }
    } else if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Enter a password to update')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 16),
            CustomTextField(
              label: 'Name',
              controller: _nameController,
              errorText: _nameError,
              onChanged:
                  (value) => setState(() {
                    _nameError = User.validateName(value);
                  }),
            ),
            SizedBox(height: 16),
            CustomTextField(
              label: 'Username',
              controller: _usernameController,
              errorText: _usernameError,
              onChanged:
                  (value) => setState(() {
                    _usernameError = User.validateUsername(value);
                  }),
            ),
            SizedBox(height: 16),
            CustomTextField(
              label: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              errorText: _emailError,
              onChanged:
                  (value) => setState(() {
                    _emailError = User.validateEmail(value);
                  }),
            ),
            SizedBox(height: 16),
            CustomTextField(
              label: 'Phone Number (Optional)',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              errorText: _phoneError,
              onChanged:
                  (value) => setState(() {
                    _phoneError = User.validatePhone(value);
                  }),
            ),
            SizedBox(height: 16),
            CustomTextField(
              label: 'Bio (Optional)',
              controller: _bioController,
              errorText: _bioError,
              onChanged:
                  (value) => setState(() {
                    _bioError = User.validateBio(value);
                  }),
            ),
            SizedBox(height: 16),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[400]!),
              ),
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
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 16),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[400]!),
              ),
              leading:
                  _profilePicture == null
                      ? Icon(Icons.image)
                      : Image.file(
                        _profilePicture!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
              title: Text('Change Profile Picture (Optional)'),
              onTap: _pickImage,
            ),
            SizedBox(height: 24),
            CustomButton(
              text: 'Update Profile',
              onPressed: _validateAndUpdateProfile,
              isLoading: _isLoading,
            ),
            SizedBox(height: 32),
            Text(
              'Change Password',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 16),
            CustomTextField(
              label: 'New Password (Optional)',
              controller: _passwordController,
              obscureText: true,
              errorText: _passwordError,
              onChanged:
                  (value) => setState(() {
                    _passwordError =
                        value.isEmpty
                            ? null
                            : value.length < 8
                            ? 'Password must be at least 8 characters'
                            : !RegExp(
                              r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
                            ).hasMatch(value)
                            ? 'Password must contain letters and numbers'
                            : null;
                  }),
            ),
            SizedBox(height: 24),
            CustomButton(
              text: 'Update Password',
              onPressed: _validateAndUpdatePassword,
              isLoading: _isLoading,
            ),
            SizedBox(height: 32),
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
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
          ],
        ),
      ),
    );
  }
}
