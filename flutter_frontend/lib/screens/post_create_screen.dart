import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class PostCreateScreen extends StatefulWidget {
  @override
  _PostCreateScreenState createState() => _PostCreateScreenState();
}

class _PostCreateScreenState extends State<PostCreateScreen> {
  final _contentController = TextEditingController();
  File? _image;
  bool _isLoading = false;

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

  void _createPost() async {
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Content is required')));
      return;
    }

    setState(() => _isLoading = true);
    final success = await Provider.of<PostProvider>(
      context,
      listen: false,
    ).createPost(_contentController.text, _image);
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Post')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(label: 'Caption', controller: _contentController),
            SizedBox(height: 16),
            ListTile(
              leading:
                  _image == null
                      ? Icon(Icons.image)
                      : Image.file(
                        _image!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
              title: Text('Select Image'),
              onTap: _pickImage,
            ),
            SizedBox(height: 16),
            CustomButton(
              text: 'Submit',
              onPressed: _createPost,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
