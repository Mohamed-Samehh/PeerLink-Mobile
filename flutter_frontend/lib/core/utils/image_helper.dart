import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageHelper {
  static Future<File?> pickImage({
    required BuildContext context,
    required ImageSource source,
  }) async {
    // Request permissions
    PermissionStatus status;
    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
    } else {
      status = await Permission.photos.request();
    }

    if (!context.mounted) return null;

    if (status.isDenied) {
      _showSnackBar(context, 'Permission denied');
      return null;
    }

    if (status.isPermanentlyDenied) {
      // Show dialog to open app settings
      await _showPermissionDialog(context);
      return null;
    }

    // Pick image
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1000,
      );

      if (!context.mounted) return null;

      if (pickedFile == null) return null;

      return File(pickedFile.path);
    } catch (e) {
      if (!context.mounted) return null;

      _showSnackBar(context, 'Error picking image: $e');
      return null;
    }
  }

  static void _showSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  static Future<void> _showPermissionDialog(BuildContext context) async {
    if (!context.mounted) return;

    final result = await showDialog<bool>(
      context: context,
      builder:
          (BuildContext dialogContext) => AlertDialog(
            title: const Text('Permission Required'),
            content: const Text(
              'This app needs permission to access your photos/camera. Please grant this permission in app settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext, true);
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
    );

    if (!context.mounted) return;

    if (result == true) {
      await openAppSettings();
    }
  }

  static ImageProvider getImageProvider(String? url, File? file) {
    if (file != null) {
      return FileImage(file);
    } else if (url != null && url.isNotEmpty) {
      return NetworkImage(url);
    } else {
      return const AssetImage('assets/images/default_profile.png');
    }
  }
}
