import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../home_screen.dart';
import '../../models/user.dart';

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
  String? _nameError;
  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _phoneError;
  String? _bioError;
  String? _dobError;
  String? _genderError;
  String? _pictureError;

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
        _pictureError = null;
      });
    }
  }

  void _validateAndRegister() async {
    setState(() {
      _nameError = User.validateName(_nameController.text);
      _usernameError = User.validateUsername(_usernameController.text);
      _emailError = User.validateEmail(_emailController.text);
      _passwordError =
          _passwordController.text.isEmpty
              ? 'Password is required'
              : _passwordController.text.length < 8
              ? 'Password must be at least 8 characters'
              : !RegExp(
                r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
              ).hasMatch(_passwordController.text)
              ? 'Password must contain letters and numbers'
              : null;
      _phoneError = User.validatePhone(_phoneController.text);
      _bioError = User.validateBio(_bioController.text);
      _dobError = _dob == null ? 'Date of birth is required' : null;
      _genderError = _gender == null ? 'Gender is required' : null;
      _pictureError =
          _profilePicture == null ? 'Profile picture is required' : null;
    });

    if (_agreeToTerms &&
        _nameError == null &&
        _usernameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _phoneError == null &&
        _bioError == null &&
        _dobError == null &&
        _genderError == null &&
        _pictureError == null) {
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
        phoneNum: _phoneController.text.isEmpty ? null : _phoneController.text,
        bio: _bioController.text.isEmpty ? null : _bioController.text,
        profilePicture: _profilePicture!,
      );
      setState(() => _isLoading = false);

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        final error = Provider.of<AuthProvider>(context, listen: false).error;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error ?? 'Registration failed')));
      }
    } else {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Please agree to terms')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Join PeerLink',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Create your account',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              SizedBox(height: 24),
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
                label: 'Password',
                controller: _passwordController,
                obscureText: true,
                errorText: _passwordError,
                onChanged:
                    (value) => setState(() {
                      _passwordError =
                          value.isEmpty
                              ? 'Password is required'
                              : value.length < 8
                              ? 'Password must be at least 8 characters'
                              : !RegExp(
                                r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
                              ).hasMatch(value)
                              ? 'Password must contain letters and numbers'
                              : null;
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
                tileColor: _dobError != null ? Colors.red[50] : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: _dobError != null ? Colors.red : Colors.grey[400]!,
                  ),
                ),
                title: Text(
                  _dob == null
                      ? 'Select Date of Birth'
                      : _dob!.toString().split(' ')[0],
                  style: TextStyle(
                    color: _dobError != null ? Colors.red : Colors.black,
                  ),
                ),
                trailing: Icon(
                  Icons.calendar_today,
                  color: _dobError != null ? Colors.red : null,
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      _dob = date;
                      _dobError = null;
                    });
                  }
                },
              ),
              if (_dobError != null)
                Padding(
                  padding: EdgeInsets.only(top: 8, left: 16),
                  child: Text(_dobError!, style: TextStyle(color: Colors.red)),
                ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _gender,
                hint: Text('Select Gender'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  errorText: _genderError,
                ),
                items:
                    ['Male', 'Female'].map((gender) {
                      return DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      );
                    }).toList(),
                onChanged:
                    (value) => setState(() {
                      _gender = value;
                      _genderError = null;
                    }),
              ),
              SizedBox(height: 16),
              ListTile(
                tileColor: _pictureError != null ? Colors.red[50] : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color:
                        _pictureError != null ? Colors.red : Colors.grey[400]!,
                  ),
                ),
                leading:
                    _profilePicture == null
                        ? Icon(
                          Icons.image,
                          color: _pictureError != null ? Colors.red : null,
                        )
                        : Image.file(
                          _profilePicture!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                title: Text(
                  'Select Profile Picture',
                  style: TextStyle(
                    color: _pictureError != null ? Colors.red : Colors.black,
                  ),
                ),
                onTap: _pickImage,
              ),
              if (_pictureError != null)
                Padding(
                  padding: EdgeInsets.only(top: 8, left: 16),
                  child: Text(
                    _pictureError!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: 16),
              CheckboxListTile(
                title: Text('I agree to the Terms & Conditions'),
                value: _agreeToTerms,
                activeColor: Theme.of(context).primaryColor,
                onChanged:
                    (value) => setState(() => _agreeToTerms = value ?? false),
              ),
              SizedBox(height: 24),
              CustomButton(
                text: 'Create Account',
                onPressed: _validateAndRegister,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
