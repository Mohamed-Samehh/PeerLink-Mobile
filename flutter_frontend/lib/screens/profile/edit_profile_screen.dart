import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../core/providers/user_provider.dart';
import '../../core/utils/form_validators.dart';
import '../../core/utils/image_helper.dart';
import '../../core/constants/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedGender;
  File? _profileImage;
  String? _currentProfileUrl;
  bool _removeProfilePicture = false;

  final List<String> _genders = ['Male', 'Female'];
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeForm();
      _isInitialized = true;
    }
  }

  void _initializeForm() {
    final userProvider = context.read<UserProvider>();
    final user = userProvider.currentUser;

    if (user != null) {
      _nameController.text = user.name;
      _usernameController.text = user.username;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNum ?? '';
      _bioController.text = user.bio ?? '';
      _selectedGender = user.gender;
      _selectedDate = DateTime.parse(user.dob);
      _currentProfileUrl = user.profilePictureUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await ImageHelper.pickImage(context: context, source: source);

    if (image != null) {
      setState(() {
        _profileImage = image;
        _removeProfilePicture = false;
      });
    }
  }

  void _showImageSourceModal() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Take a photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_currentProfileUrl != null || _profileImage != null)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text(
                      'Remove profile picture',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _profileImage = null;
                        _removeProfilePicture = true;
                      });
                    },
                  ),
              ],
            ),
          ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select your date of birth'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      if (_selectedGender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select your gender'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      final userProvider = context.read<UserProvider>();

      final success = await userProvider.updateProfile(
        name: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        dob: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        gender: _selectedGender!,
        phoneNum:
            _phoneController.text.trim().isNotEmpty
                ? _phoneController.text.trim()
                : null,
        bio:
            _bioController.text.trim().isNotEmpty
                ? _bioController.text.trim()
                : null,
        profilePicture: _profileImage,
        removeProfilePicture: _removeProfilePicture,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        if (userProvider.validationErrors != null) {
          String errorMessage = '';
          userProvider.validationErrors!.forEach((key, value) {
            if (value is List) {
              for (var error in value) {
                errorMessage += '${error.toString()}\n';
              }
            } else {
              errorMessage += '${value.toString()}\n';
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 5),
            ),
          );
        } else if (userProvider.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(userProvider.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: AppColors.primary),
        title: const Text('Edit Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body:
          userProvider.isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Profile picture
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: AppColors.primaryLight,
                              backgroundImage:
                                  _removeProfilePicture
                                      ? null
                                      : (_profileImage != null
                                          ? FileImage(_profileImage!)
                                          : (_currentProfileUrl != null
                                              ? NetworkImage(
                                                _currentProfileUrl!,
                                              )
                                              : null)),
                              child:
                                  (_removeProfilePicture ||
                                          (_profileImage == null &&
                                              _currentProfileUrl == null))
                                      ? const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.white,
                                      )
                                      : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                backgroundColor: AppColors.primary,
                                radius: 20,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: _showImageSourceModal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          "Profile Picture",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Name field
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                FormValidators.validateRequired(value, 'Name'),
                        textInputAction: TextInputAction.next,
                        enabled: !userProvider.isLoading,
                      ),
                      const SizedBox(height: 16),

                      // Username field
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.alternate_email),
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) => FormValidators.validateUsername(value),
                        textInputAction: TextInputAction.next,
                        enabled: !userProvider.isLoading,
                      ),
                      const SizedBox(height: 16),

                      // Email field
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) => FormValidators.validateEmail(value),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        enabled: !userProvider.isLoading,
                      ),
                      const SizedBox(height: 16),

                      // Phone field (optional)
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number (optional)',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) => FormValidators.validatePhone(value),
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        enabled: !userProvider.isLoading,
                      ),
                      const SizedBox(height: 16),

                      // Date of birth field
                      GestureDetector(
                        onTap: !userProvider.isLoading ? _selectDate : null,
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Date of Birth',
                              prefixIcon: Icon(Icons.calendar_today),
                              border: OutlineInputBorder(),
                            ),
                            controller: TextEditingController(
                              text:
                                  _selectedDate == null
                                      ? ''
                                      : DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(_selectedDate!),
                            ),
                            validator:
                                (value) => FormValidators.validateRequired(
                                  value,
                                  'Date of Birth',
                                ),
                            enabled: !userProvider.isLoading,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Gender dropdown
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                          prefixIcon: Icon(Icons.people),
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedGender,
                        items:
                            _genders.map((gender) {
                              return DropdownMenuItem<String>(
                                value: gender,
                                child: Text(gender),
                              );
                            }).toList(),
                        onChanged:
                            userProvider.isLoading
                                ? null
                                : (value) {
                                  setState(() {
                                    _selectedGender = value;
                                  });
                                },
                        validator:
                            (value) => FormValidators.validateGender(value),
                      ),
                      const SizedBox(height: 16),

                      // Bio field (optional)
                      TextFormField(
                        controller: _bioController,
                        decoration: const InputDecoration(
                          labelText: 'Bio (optional)',
                          prefixIcon: Icon(Icons.info),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => FormValidators.validateBio(value),
                        maxLines: 3,
                        maxLength: 100,
                        enabled: !userProvider.isLoading,
                      ),
                      const SizedBox(height: 24),

                      // Update button
                      ElevatedButton(
                        onPressed:
                            userProvider.isLoading ? null : _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child:
                            userProvider.isLoading
                                ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text('UPDATE PROFILE'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
