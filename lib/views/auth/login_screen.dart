import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/responsive_utils.dart';
import 'register_screen.dart';
import 'reset_password_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: ResponsiveBuilder(
        builder: (context, isMobile, isTablet, isDesktop) {
          return Center(
            child: SingleChildScrollView(
              padding: ResponsiveUtils.getScreenPadding(context),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 400 : double.infinity,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo or App Title
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: ResponsiveUtils.getLargeSpacing(context),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: ResponsiveUtils.getIconSize(context) / 2,
                            backgroundColor:
                                theme.primaryColor.withOpacity(0.1),
                            child: Icon(
                              Icons.access_time,
                              size: ResponsiveUtils.getIconSize(context),
                              color: theme.primaryColor,
                            ),
                          ),
                          SizedBox(
                              height: ResponsiveUtils.getSmallSpacing(context)),
                          Text(
                            'Employee Attendance',
                            style: TextStyle(
                              fontSize:
                                  ResponsiveUtils.getTitleFontSize(context),
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            ResponsiveUtils.getCardBorderRadius(context),
                      ),
                      margin: EdgeInsets.symmetric(
                        horizontal:
                            ResponsiveUtils.getHorizontalPadding(context),
                      ),
                      child: Padding(
                        padding:
                            ResponsiveUtils.getCardPaddingEdgeInsets(context),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  size:
                                      ResponsiveUtils.getIconSize(context) - 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(
                                height: ResponsiveUtils.getSpacing(context)),
                            TextField(
                              controller: passwordController,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  size:
                                      ResponsiveUtils.getIconSize(context) - 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              obscureText: true,
                            ),
                            SizedBox(
                                height:
                                    ResponsiveUtils.getLargeSpacing(context)),
                            Obx(
                              () => authController.isLoading.value
                                  ? const CircularProgressIndicator()
                                  : SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                            vertical:
                                                ResponsiveUtils.getSpacing(
                                                    context),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          backgroundColor: theme.primaryColor,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () async {
                                          if (emailController.text.isEmpty ||
                                              passwordController.text.isEmpty) {
                                            Get.snackbar(
                                              'Error',
                                              'Please fill in all fields',
                                              snackPosition: SnackPosition.TOP,
                                              backgroundColor: Colors.red,
                                              colorText: Colors.white,
                                            );
                                            return;
                                          }
                                          await authController.signIn(
                                            emailController.text,
                                            passwordController.text,
                                          );
                                        },
                                        child: Text(
                                          'Sign In',
                                          style: TextStyle(
                                            fontSize:
                                                ResponsiveUtils.getBodyFontSize(
                                                    context),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                            SizedBox(
                                height: ResponsiveUtils.getSpacing(context)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Get.to(() => RegisterScreen());
                                  },
                                  child: Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: ResponsiveUtils.getBodyFontSize(
                                          context),
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Get.to(() => ResetPasswordScreen());
                                  },
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      fontSize: ResponsiveUtils.getBodyFontSize(
                                          context),
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
