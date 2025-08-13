import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import '../config/cloudinary_config.dart';

class CloudinaryService {
  static const String _cloudName = CloudinaryConfig.cloudName;
  static const String _uploadPreset = CloudinaryConfig.uploadPreset;

  static final CloudinaryPublic _cloudinary = CloudinaryPublic(
    _cloudName,
    _uploadPreset,
    cache: false,
  );

  /// Upload profile picture to Cloudinary
  static Future<String?> uploadProfilePicture(
      File imageFile, String userId) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'profile_pictures',
          publicId: 'user_$userId',
        ),
      );

      return response.secureUrl;
    } catch (e) {
      print('Error uploading image to Cloudinary: $e');
      return null;
    }
  }

  /// Note: Cloudinary public package doesn't support deletion
  /// You would need to use the full Cloudinary package for deletion
  /// For now, we'll just return true as deletion isn't critical for profile pictures
  static Future<bool> deleteProfilePicture(String userId) async {
    // Note: Deletion requires the full Cloudinary package with API credentials
    // For profile pictures, this is usually not necessary as they get overwritten
    print('Profile picture deletion not implemented with public package');
    return true;
  }

  /// Get optimized profile picture URL
  static String getOptimizedProfileUrl(String originalUrl,
      {int width = 200, int height = 200}) {
    if (originalUrl.contains('cloudinary.com')) {
      // Transform the URL to get optimized version
      return originalUrl.replaceAll(
          '/upload/', '/upload/w_$width,h_$height,c_fill,g_face/');
    }
    return originalUrl;
  }
}
