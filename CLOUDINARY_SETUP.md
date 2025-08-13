# Cloudinary Setup Guide

## Overview
This app now uses Cloudinary for profile picture storage instead of Firebase Storage. Cloudinary provides a generous free tier and better image optimization features.

## Setup Steps

### 1. Create Cloudinary Account
1. Go to [Cloudinary.com](https://cloudinary.com)
2. Sign up for a free account
3. Verify your email

### 2. Get Your Credentials
1. Log into your Cloudinary Dashboard
2. Go to **Settings** → **Access Keys**
3. Copy your **Cloud Name**
4. Go to **Settings** → **Upload**
5. Create a new **Upload Preset**:
   - Set **Signing Mode** to "Unsigned"
   - Set **Folder** to "profile_pictures" (optional)
   - Copy the **Preset Name**

### 3. Configure the App
1. Open `lib/config/cloudinary_config.dart`
2. Replace the placeholder values:
   ```dart
   static const String cloudName = 'your_actual_cloud_name';
   static const String uploadPreset = 'your_actual_preset_name';
   ```

### 4. Test the Integration
1. Run the app: `flutter run`
2. Go to Profile screen
3. Try uploading a profile picture
4. Check if it appears in your Cloudinary dashboard

## Features

### ✅ What's Working
- **Profile Picture Upload**: Users can upload profile pictures
- **Image Optimization**: Automatic resizing and optimization
- **CDN Delivery**: Fast image loading worldwide
- **Free Tier**: 25GB storage, 25GB bandwidth per month

### 🔧 Technical Details
- **Upload Method**: Unsigned uploads (no API key required)
- **Image Transformations**: Automatic face detection and cropping
- **Storage**: Images stored in "profile_pictures" folder
- **Naming**: Files named as "user_[userId]"

### 📱 App Integration
- **Employee Profile**: Upload/update profile pictures
- **Admin Create User**: Set profile picture during user creation
- **Dashboard Display**: Show optimized profile pictures
- **Firestore Sync**: Store image URLs in user documents

## Troubleshooting

### Common Issues
1. **Upload Fails**: Check your cloud name and upload preset
2. **Images Don't Load**: Verify the URL format in Firestore
3. **Permission Errors**: Ensure upload preset is set to "Unsigned"

### Debug Steps
1. Check console logs for upload errors
2. Verify Cloudinary credentials in config file
3. Test upload preset in Cloudinary dashboard
4. Check Firestore for correct photoUrl values

## Migration from Firebase Storage
- ✅ Profile pictures now use Cloudinary
- ✅ Existing Firebase Storage code removed
- ✅ All uploads go to Cloudinary
- ✅ URLs stored in Firestore as before

## Next Steps
- Consider adding image compression before upload
- Implement image deletion for unused profiles
- Add image validation (size, format, etc.)
- Consider using signed uploads for better security 