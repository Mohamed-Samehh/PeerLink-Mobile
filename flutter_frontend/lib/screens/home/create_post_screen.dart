import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/providers/post_provider.dart';
import '../../core/utils/image_helper.dart';
import '../../core/constants/app_colors.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _contentController = TextEditingController();
  File? _postImage;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await ImageHelper.pickImage(context: context, source: source);

    if (image != null) {
      setState(() {
        _postImage = image;
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
              ],
            ),
          ),
    );
  }

  void _removeImage() {
    setState(() {
      _postImage = null;
    });
  }

  Future<void> _createPost() async {
    if (_formKey.currentState!.validate()) {
      final postProvider = context.read<PostProvider>();

      final success = await postProvider.createPost(
        content: _contentController.text,
        image: _postImage,
      );

      if (success && mounted) {
        // Reset form
        _contentController.clear();
        setState(() {
          _postImage = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (mounted) {
        if (postProvider.validationErrors != null) {
          String errorMessage = '';
          postProvider.validationErrors!.forEach((key, value) {
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
        } else if (postProvider.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(postProvider.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = context.watch<PostProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Post content
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                hintText: "What's on your mind?",
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some content';
                }
                return null;
              },
              enabled: !postProvider.isCreatingPost,
            ),
            const SizedBox(height: 16),

            // Image preview
            if (_postImage != null)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: FileImage(_postImage!),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  IconButton(
                    icon: const CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.close, color: Colors.white),
                    ),
                    onPressed: _removeImage,
                  ),
                ],
              ),

            const SizedBox(height: 16),

            // Add image button
            OutlinedButton.icon(
              onPressed:
                  postProvider.isCreatingPost ? null : _showImageSourceModal,
              icon: const Icon(Icons.image),
              label: const Text('Add Image (Optional)'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                foregroundColor: AppColors.primary,
              ),
            ),

            const SizedBox(height: 24),

            // Create post button
            ElevatedButton(
              onPressed: postProvider.isCreatingPost ? null : _createPost,
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
                  postProvider.isCreatingPost
                      ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Text('POST'),
            ),
          ],
        ),
      ),
    );
  }
}
