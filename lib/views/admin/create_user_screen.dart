import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth_service.dart';
import '../../services/cloudinary_service.dart';
import 'dart:io';
import '../../controllers/auth_controller.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  String _role = 'employee';
  bool _isLoading = false;
  String? _error;
  XFile? _pickedImage;
  String? _uploadedPhotoUrl;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = picked;
      });
    }
  }

  Future<String?> _uploadProfilePic(String uid) async {
    if (_pickedImage == null) return null;
    return await CloudinaryService.uploadProfilePicture(
      File(_pickedImage!.path),
      uid,
    );
  }

  Future<void> _createUser() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final authController = Get.find<AuthController>();

    try {
      // Upload profile picture if picked
      String? photoUrl;
      if (_pickedImage != null) {
        photoUrl = await _uploadProfilePic(
            'temp_${DateTime.now().millisecondsSinceEpoch}');
      }

      // Create user without auto-login using the new method
      await AuthService().createUserWithoutLogin(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _displayNameController.text.trim(),
        _role,
        photoUrl,
        authController:
            authController, // Pass the controller to manage the flag
      );

      // Clear form
      _emailController.clear();
      _passwordController.clear();
      _displayNameController.clear();
      setState(() {
        _role = 'employee';
        _pickedImage = null;
        _uploadedPhotoUrl = null;
      });

      // Show dialog asking admin to re-enter credentials
      final result = await _showReauthDialog();
      if (result != null) {
        // Try to re-authenticate as admin
        try {
          final email = result['email'];
          final password = result['password'];
          if (email != null && password != null) {
            await AuthService().signIn(email, password);
            Get.back(); // Close the create user screen
            Get.snackbar(
              'Success',
              'User created successfully as $_role!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green.shade50,
              colorText: Colors.green.shade900,
            );
          }
        } catch (e) {
          Get.snackbar(
            'Error',
            'Failed to re-authenticate. Please log in again.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade900,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, String>?> _showReauthDialog() async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return await Get.dialog<Map<String, String>>(
      AlertDialog(
        title: const Text('Re-authenticate as Admin'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please re-enter your admin credentials to continue.'),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Admin Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Admin Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (emailController.text.isNotEmpty &&
                  passwordController.text.isNotEmpty) {
                Get.back(result: {
                  'email': emailController.text.trim(),
                  'password': passwordController.text.trim(),
                });
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create User'),
        backgroundColor: theme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter email' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (val) =>
                    val == null || val.length < 6 ? 'Min 6 chars' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 36,
                    backgroundImage: _pickedImage != null
                        ? FileImage(File(_pickedImage!.path))
                        : null,
                    backgroundColor: theme.primaryColor.withOpacity(0.1),
                    child: _pickedImage == null
                        ? Icon(Icons.camera_alt,
                            size: 36, color: theme.primaryColor)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'employee', child: Text('Employee')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'hr', child: Text('HR')),
                ],
                onChanged: (val) => setState(() => _role = val ?? 'employee'),
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _createUser();
                          }
                        },
                        child: const Text(
                          'Create User',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _error!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
