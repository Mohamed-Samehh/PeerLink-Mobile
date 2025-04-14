import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../home_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  DateTime? _dob;
  String? _gender;
  File? _profilePicture;
  bool _isLoading = false;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
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

  void _register() async {
    if (!_agreeToTerms ||
        _dob == null ||
        _gender == null ||
        _profilePicture == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please complete all fields and agree to terms'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final success = await Provider.of<AuthProvider>(
      context,
      listen: false,
    ).register(
      name: _nameController.text,
      username: _usernameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      dob: _dob!.toIso8601String().split('T')[0],
      gender: _gender!,
      phoneNum: _phoneController.text,
      bio: _bioController.text,
      profilePicture: _profilePicture!,
    );
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(
              label: 'Name',
              controller: _nameController,
              errorText:
                  authProvider.error!.contains('name')
                      ? authProvider.error
                      : null,
            ),
            SizedBox(height: 16),
            CustomTextField(
              label: 'Username',
              controller: _usernameController,
              errorText:
                  authProvider.error!.contains('username')
                      ? authProvider.error
                      : null,
            ),
            SizedBox(height: 16),
            CustomTextField(
              label: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              errorText:
                  authProvider.error!.contains('email')
                      ? authProvider.error
                      : null,
            ),
            SizedBox(height: 16),
            CustomTextField(
              label: 'Password',
              controller: _passwordController,
              obscureText: true,
              errorText:
                  authProvider.error!.contains('password')
                      ? authProvider.error
                      : null,
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
                  initialDate: DateTime.now(),
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
              title: Text('Select Profile Picture'),
              onTap: _pickImage,
            ),
            SizedBox(height: 16),
            CheckboxListTile(
              title: Text('Agree to Terms & Conditions'),
              value: _agreeToTerms,
              onChanged:
                  (value) => setState(() => _agreeToTerms = value ?? false),
            ),
            SizedBox(height: 16),
            CustomButton(
              text: 'Create Account',
              onPressed: _register,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
