import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../models/post.dart';

class PostCreateScreen extends StatefulWidget {
  @override
  _PostCreateScreenState createState() => _PostCreateScreenState();
}

class _PostCreateScreenState extends State<PostCreateScreen> {
  final _contentController = TextEditingController();
  File? _image;
  bool _isLoading = false;
  String? _contentError;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _validateAndCreatePost() async {
    setState(() {
      _contentError = Post.validateContent(_contentController.text);
    });

    if (_contentError == null) {
      setState(() => _isLoading = true);
      final success = await Provider.of<PostProvider>(
        context,
        listen: false,
      ).createPost(_contentController.text, _image);
      setState(() => _isLoading = false);

      if (success) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Provider.of<PostProvider>(context, listen: false).error ??
                  'Failed to create post',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share Something',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 16),
            CustomTextField(
              label: 'What’s on your mind?',
              controller: _contentController,
              maxLines: 5,
              errorText: _contentError,
              onChanged:
                  (value) => setState(() {
                    _contentError = Post.validateContent(value);
                  }),
            ),
            SizedBox(height: 16),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[400]!),
              ),
              leading:
                  _image == null
                      ? Icon(Icons.image)
                      : Image.file(
                        _image!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
              title: Text('Add Image (Optional)'),
              onTap: _pickImage,
            ),
            SizedBox(height: 24),
            CustomButton(
              text: 'Post',
              onPressed: _validateAndCreatePost,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
