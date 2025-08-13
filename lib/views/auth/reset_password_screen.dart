import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/responsive_utils.dart';

class ResetPasswordScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  ResetPasswordScreen({super.key});

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
                              Icons.lock_reset,
                              size: ResponsiveUtils.getIconSize(context),
                              color: theme.primaryColor,
                            ),
                          ),
                          SizedBox(
                              height: ResponsiveUtils.getSmallSpacing(context)),
                          Text(
                            'Reset Password',
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
                                          FocusScope.of(context).unfocus();
                                          await authController
                                              .sendPasswordResetEmail(
                                            emailController.text.trim(),
                                          );
                                          if (authController
                                              .errorMessage.value.isEmpty) {
                                            Get.snackbar(
                                              'Success',
                                              'Password reset email sent.',
                                              backgroundColor:
                                                  Colors.green.shade50,
                                              colorText: Colors.green.shade900,
                                              snackPosition:
                                                  SnackPosition.BOTTOM,
                                            );
                                          }
                                        },
                                        child: Text(
                                          'Send Password Reset Email',
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
                            Obx(
                              () => authController.errorMessage.value.isNotEmpty
                                  ? Padding(
                                      padding: EdgeInsets.only(
                                        top:
                                            ResponsiveUtils.getSpacing(context),
                                      ),
                                      child: Text(
                                        authController.errorMessage.value,
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.w500,
                                          fontSize:
                                              ResponsiveUtils.getBodyFontSize(
                                                  context),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                            ),
                            SizedBox(
                                height: ResponsiveUtils.getSpacing(context)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  child: Text(
                                    'Back to Login',
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
