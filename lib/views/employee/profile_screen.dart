import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controllers/auth_controller.dart';
import '../../services/cloudinary_service.dart';
import '../../utils/responsive_utils.dart';

class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({super.key});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _imagePicker = ImagePicker();
  XFile? _pickedImage;
  String? _currentPhotoUrl;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final userModel = Get.find<AuthController>().userModel.value;
    if (userModel != null) {
      _displayNameController.text = userModel.displayName ?? '';
      _currentPhotoUrl = userModel.photoUrl;
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _pickedImage = image;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authController = Get.find<AuthController>();
      String? photoUrl = _currentPhotoUrl;

      // Upload new image if selected
      if (_pickedImage != null) {
        photoUrl = await CloudinaryService.uploadProfilePicture(
          File(_pickedImage!.path),
          authController.user.value!.uid,
        );
      }

      // Update Firebase Auth display name
      await authController.user.value!
          .updateDisplayName(_displayNameController.text.trim());

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(authController.user.value!.uid)
          .update({
        'displayName': _displayNameController.text.trim(),
        'photoUrl': photoUrl,
      });

      // Refresh user model
      await authController.refreshUserModel();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Get.snackbar(
          'Success',
          'Profile updated successfully!',
          backgroundColor: Colors.green.shade50,
          colorText: Colors.green.shade900,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: ResponsiveBuilder(
        builder: (context, isMobile, isTablet, isDesktop) {
          return SingleChildScrollView(
            padding: ResponsiveUtils.getScreenPadding(context),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: ResponsiveUtils.getIconSize(context),
                      backgroundImage: _pickedImage != null
                          ? FileImage(File(_pickedImage!.path))
                          : (_currentPhotoUrl != null &&
                                  _currentPhotoUrl!.isNotEmpty)
                              ? NetworkImage(_currentPhotoUrl!) as ImageProvider
                              : null,
                      child: (_pickedImage == null &&
                              (_currentPhotoUrl == null ||
                                  _currentPhotoUrl!.isEmpty))
                          ? Icon(
                              Icons.camera_alt,
                              size: ResponsiveUtils.getIconSize(context),
                            )
                          : null,
                    ),
                  ),
                  // Debug info
                  if (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(
                        top: ResponsiveUtils.getSmallSpacing(context),
                      ),
                      child: Text(
                        'Current photo: ${_currentPhotoUrl!.substring(0, 50)}...',
                        style: TextStyle(
                          fontSize:
                              ResponsiveUtils.getBodyFontSize(context) - 4,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  SizedBox(height: ResponsiveUtils.getLargeSpacing(context)),
                  TextFormField(
                    controller: _displayNameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Enter name' : null,
                  ),
                  SizedBox(height: ResponsiveUtils.getLargeSpacing(context)),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: ResponsiveUtils.getSpacing(context),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _saveProfile();
                              }
                            },
                            child: Text(
                              'Save',
                              style: TextStyle(
                                fontSize:
                                    ResponsiveUtils.getBodyFontSize(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                  if (_error != null)
                    Padding(
                      padding: EdgeInsets.only(
                        top: ResponsiveUtils.getSpacing(context),
                      ),
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: ResponsiveUtils.getBodyFontSize(context),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
